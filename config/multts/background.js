// MultiTTS Read Aloud — service worker
// 负责: 跨域请求 TTS API(带 host_permissions 免 CORS)、语音列表、设置存储、命令分发

const DEFAULTS = {
  baseUrl: 'http://192.168.10.3:8774', // MultiTTS HTTP 服务地址
  voice: '',
  rate: 1.0,    // 语速倍率, MultiTTS speed = rate*50
  volume: 50,   // 0-100
  pitch: 50     // 0-100
};

chrome.runtime.onInstalled.addListener(() => {
  chrome.contextMenus.create({
    id: 'mra-read',
    title: '大声朗读',
    contexts: ['page', 'selection']
  });
});

async function getSettings() {
  return { ...DEFAULTS, ...(await chrome.storage.sync.get(DEFAULTS)) };
}

// 从 API 错误响应中提取可读信息, 如 {"success":false,"error":{"message":"Speaker not found:..."}}
async function apiError(resp) {
  try {
    const data = await resp.json();
    if (data && data.error && data.error.message) return data.error.message;
  } catch (_) {}
  return 'HTTP ' + resp.status;
}

function forwardUrl(base) {
  return base.replace(/\/+$/, '') + '/forward';
}

// 扩展消息是 JSON 序列化的, ArrayBuffer 无法直接传递 -> base64
function bufToB64(buffer) {
  const bytes = new Uint8Array(buffer);
  let bin = '';
  const CH = 0x8000; // 分块避免 String.fromCharCode 参数上限
  for (let i = 0; i < bytes.length; i += CH) {
    bin += String.fromCharCode.apply(null, bytes.subarray(i, i + CH));
  }
  return btoa(bin);
}

// GET /forward?text=&voice=&speed=&volume=&pitch= -> 音频字节(audio/x-wav)
async function fetchTts(text) {
  const s = await getSettings();
  const qs = new URLSearchParams({
    text,
    voice: s.voice || '',
    speed: String(Math.round(s.rate * 50)),

    volume: String(s.volume),
    pitch: String(s.pitch)
  });
  const resp = await fetch(forwardUrl(s.baseUrl) + '?' + qs.toString());
  if (!resp.ok) throw new Error(await apiError(resp));
  const buffer = await resp.arrayBuffer();
  const mime = resp.headers.get('content-type') || 'audio/wav';
  return { buffer, mime };
}

// GET /voices -> 展平 catalog (真实返回形如 {"success":true,"data":{"catalog":{"microsoft":[{id:"microsoft_zh-CN-XiaoxiaoNeural",name:"晓晓",gender,locale,desc,type}]}}})
async function fetchVoices() {
  const s = await getSettings();
  const resp = await fetch(s.baseUrl.replace(/\/+$/, '') + '/voices');
  if (!resp.ok) throw new Error(await apiError(resp));
  const data = await resp.json();
  if (!data.success) throw new Error((data.error && data.error.message) || 'voices 接口返回失败');
  const voices = Object.values(data.data.catalog).flat().map(v => ({
    id: v.id, name: v.name, locale: v.locale || '', gender: v.gender || '', desc: v.desc || ''
  }));
  return voices;
}

// ---------- offscreen 音频播放 ----------
const OFFSCREEN_URL = 'offscreen.html';
let creatingOffscreen = null;

async function hasOffscreen() {
  const ctx = await chrome.runtime.getContexts({
    contextTypes: ['OFFSCREEN_DOCUMENT']
  });
  return ctx.length > 0;
}

async function ensureOffscreen() {
  try { if (await hasOffscreen()) return; } catch (_) {} // getContexts 不可用时靠下面的错误兜底
  if (!creatingOffscreen) {
    creatingOffscreen = chrome.offscreen.createDocument({
      url: OFFSCREEN_URL,
      reasons: ['AUDIO_PLAYBACK'],
      justification: '播放 MultiTTS 合成的朗读语音'
    }).finally(() => { creatingOffscreen = null; });
  }
  try {
    await creatingOffscreen;
  } catch (e) {
    // 并发创建时 "Only a single offscreen document" 视为成功
    if (!String(e).includes('single offscreen')) throw e;
  }
}

async function offscreenCmd(msg) {
  await ensureOffscreen();
  return await chrome.runtime.sendMessage(msg).catch(e => ({ ok: false, error: String(e) }));
}
chrome.runtime.onMessage.addListener((msg, sender, sendResponse) => {
  (async () => {
    try {
      switch (msg.type) {
        case 'mra-tts': {
          const r = await fetchTts(msg.text);
          sendResponse({ ok: true, b64: bufToB64(r.buffer), mime: r.mime });
          break;
        }
        case 'mra-voices': {
          sendResponse({ ok: true, voices: await fetchVoices() });
          break;
        }
        case 'mra-config': {
          sendResponse({ ok: true, settings: await getSettings() });
          break;
        }
        case 'mra-test': {
          const r = await fetchTts(msg.text || '朗读测试');
          sendResponse({ ok: true, b64: bufToB64(r.buffer), mime: r.mime });
          break;
        }
        case 'mra-play-audio': {
          // 内容脚本 -> offscreen 播放; respond 在音频结束/被取代时返回
          await ensureOffscreen();
          const r = await chrome.runtime.sendMessage({
            type: 'mra-off-play', b64: msg.b64, mime: msg.mime
          }).catch(e => ({ ok: false, error: String(e) }));
          sendResponse(r);
          break;
        }
        case 'mra-audio-pause':
        case 'mra-audio-resume':
        case 'mra-audio-stop': {
          sendResponse(await offscreenCmd({ type: msg.type }));
          break;
        }
        default:
          sendResponse({ ok: false, error: 'unknown message' });
      }
    } catch (e) {
      sendResponse({ ok: false, error: String(e && e.message || e) });
    }
  })();
  return true; // 异步响应
});

// 确保内容脚本已注入(扩展刚装/未匹配页面时), 然后转发指令
async function ensureInjected(tabId) {
  try {
    await chrome.tabs.sendMessage(tabId, { type: 'mra-ping' });
    return;
  } catch (_) {}
  await chrome.scripting.executeScript({
    target: { tabId },
    files: ['content.js']
  }).catch(() => {});
}

async function sendToActiveTab(msg) {
  const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
  if (!tab || !tab.id) return;
  await ensureInjected(tab.id);
  chrome.tabs.sendMessage(tab.id, msg).catch(() => {});
}

chrome.commands.onCommand.addListener((cmd) => {
  if (cmd === 'toggle-read-aloud') sendToActiveTab({ type: 'mra-toggle' });
});

chrome.contextMenus.onClicked.addListener((info, tab) => {
  if (info.menuItemId !== 'mra-read' || !tab || !tab.id) return;
  ensureInjected(tab.id).then(() =>
    chrome.tabs.sendMessage(tab.id, {
      type: 'mra-start',
      mode: info.selectionText ? 'selection' : 'page'
    }).catch(() => {})
  );
});
