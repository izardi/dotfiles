const $ = id => document.getElementById(id);

function status(msg) { $('status').textContent = msg; }

async function load() {
  const s = { ...(await chrome.storage.sync.get({
    baseUrl: 'http://192.168.10.3:8774', voice: '', rate: 1.0, volume: 50, pitch: 50
  })) };
  $('baseUrl').value = s.baseUrl;
  $('voiceManual').value = s.voice;
  for (const k of ['rate', 'volume', 'pitch']) {
    $(k).value = s[k];
    $(k + 'Val').textContent = s[k];
  }
  loadVoices(s.baseUrl, s.voice);
}

async function loadVoices(baseUrl, currentVoice) {
  const sel = $('voice');
  sel.innerHTML = '<option value="">(加载中…)</option>';
  try {
    const r = await chrome.runtime.sendMessage({ type: 'mra-voices' });
    if (!r.ok) throw new Error(r.error);
    sel.innerHTML = '<option value="">(MultiTTS 默认)</option>';
    for (const v of r.voices) {
      const opt = document.createElement('option');
      opt.value = v.id;
      opt.textContent = `${v.name} (${v.locale || '?'})`;
      opt.selected = v.id === currentVoice;
      sel.appendChild(opt);
    }
  } catch (e) {
    sel.innerHTML = '<option value="">(无法加载列表, 可手动填写)</option>';
    if ($('voiceManual').value) $('voiceManual').value = currentVoice || '';
  }
}

$('voice').addEventListener('change', () => { $('voiceManual').value = $('voice').value; });
$('refreshVoices').addEventListener('click', async () => {
  await chrome.storage.sync.set({ baseUrl: $('baseUrl').value.trim() });
  loadVoices($('baseUrl').value.trim(), '');
});
for (const k of ['rate', 'volume', 'pitch']) {
  $(k).addEventListener('input', () => { $(k + 'Val').textContent = $(k).value; });
}

$('save').addEventListener('click', async () => {
  const manual = $('voiceManual').value.trim();
  await chrome.storage.sync.set({
    baseUrl: $('baseUrl').value.trim().replace(/\/+$/, ''),
    voice: manual || '',
    rate: parseFloat($('rate').value),
    volume: parseInt($('volume').value, 10),
    pitch: parseInt($('pitch').value, 10)
  });
  status('✓ 已保存');
});

$('test').addEventListener('click', async () => {
  status('合成中…');
  try {
    // 先保存再测试, 保证 background 用到最新配置
    $('save').click();
    const r = await chrome.runtime.sendMessage({ type: 'mra-test', text: '你好，这是大声朗读测试。' });
    if (!r.ok) throw new Error(r.error);
    const bin = atob(r.b64);
    const bytes = new Uint8Array(bin.length);
    for (let i = 0; i < bin.length; i++) bytes[i] = bin.charCodeAt(i);
    const url = URL.createObjectURL(new Blob([bytes], { type: r.mime }));
    new Audio(url).play();
    status('▶ 播放中');
  } catch (e) {
    status('✗ 失败: ' + e.message);
  }
});

load();
