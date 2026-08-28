// offscreen 音频播放器 — 扩展上下文不受网页自动播放策略限制
// 协议:
//   mra-off-play {buffer, mime}      -> 播放, 结束/被取代时 respond {ok, ended}
//   mra-audio-pause / -resume        -> 暂停/继续 (不 settle 当前 play)
//   mra-audio-stop                   -> 停止并 settle 当前 play {ok, ended:false}

const audio = document.getElementById('mra-audio');
let pending = null;   // {sendResponse}
let token = 0;        // 使旧的 play 处理失效

function settle(v) {
  if (pending) {
    const p = pending;
    pending = null;
    try { p.sendResponse(v); } catch (_) {}
  }
}

chrome.runtime.onMessage.addListener((msg, _sender, sendResponse) => {
  switch (msg.type) {
    case 'mra-off-play': {
      const my = ++token;
      settle({ ok: true, ended: false }); // 取代上一个未完成的 play

      // base64 -> 字节 (扩展消息是 JSON 序列化, 二进制必须走 base64)
      let url;
      try {
        const bin = atob(msg.b64);
        const bytes = new Uint8Array(bin.length);
        for (let i = 0; i < bin.length; i++) bytes[i] = bin.charCodeAt(i);
        url = URL.createObjectURL(new Blob([bytes], { type: msg.mime || 'audio/wav' }));
      } catch (e) {
        sendResponse({ ok: false, error: String(e) });
        return true;
      }

      pending = { sendResponse };
      const cleanup = () => URL.revokeObjectURL(url);
      audio.onended = () => { if (my === token) { cleanup(); settle({ ok: true, ended: true }); } };
      audio.onerror = () => { if (my === token) { cleanup(); settle({ ok: false, error: '音频解码失败' }); } };

      audio.src = url;
      audio.currentTime = 0;
      audio.play().catch(e => {
        if (my !== token) return;
        cleanup();
        settle({ ok: false, error: String(e && e.message || e) });
      });
      return true; // 异步 sendResponse
    }

    case 'mra-audio-pause':
      audio.pause();
      sendResponse({ ok: true });
      break;

    case 'mra-audio-resume':
      audio.play().catch(() => {});
      sendResponse({ ok: true });
      break;

    case 'mra-audio-stop':
      token++;
      audio.pause();
      audio.removeAttribute('src');
      audio.load();
      settle({ ok: true, ended: false });
      sendResponse({ ok: true });
      break;

    default:
      break; // 不接管其它消息(如 mra-config 广播)
  }
  return false;
});
