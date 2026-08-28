// MultiTTS Read Aloud — content script
// 正文提取 -> 句子切分 -> 逐句请求音频播放 -> 高亮当前句 + 自动滚动 + 悬浮控制条

(() => {
  if (window.__mraLoaded) return;
  window.__mraLoaded = true;

  const HIGHLIGHT = 'mra-highlight';
  let session = null; // 活动朗读会话

  // ---------- 设置 ----------
  function getConfig() {
    return chrome.runtime.sendMessage({ type: 'mra-config' });
  }

  // ---------- 正文提取 ----------
  const SKIP_TAGS = new Set([
    'SCRIPT', 'STYLE', 'NOSCRIPT', 'TEMPLATE', 'IFRAME', 'CANVAS', 'SVG',
    'SELECT', 'OPTION', 'BUTTON', 'INPUT', 'TEXTAREA', 'NAV', 'HEADER',
    'FOOTER', 'ASIDE', 'DIALOG', 'MENU'
  ]);

  function visible(el) {
    try { return el.checkVisibility ? el.checkVisibility() : !!(el.offsetParent || el.getClientRects().length); }
    catch (_) { return true; }
  }

  function textNodesUnder(root) {
    const out = [];
    const walker = document.createTreeWalker(root, NodeFilter.SHOW_TEXT, {
      acceptNode(n) {
        if (!n.nodeValue.trim()) return NodeFilter.FILTER_REJECT;
        const p = n.parentElement;
        if (!p) return NodeFilter.FILTER_REJECT;
        const skipAncestor = p.closest(Array.from(SKIP_TAGS).join(','));
        if (skipAncestor) return NodeFilter.FILTER_REJECT;
        if (p.closest('[aria-hidden="true"],[hidden]')) return NodeFilter.FILTER_REJECT;
        if (!visible(p)) return NodeFilter.FILTER_REJECT;
        return NodeFilter.FILTER_ACCEPT;
      }
    });
    while (walker.nextNode()) out.push(walker.currentNode);
    return out;
  }

  // 收集可见文本节点, 按块级容器分块
  function extractBlocks() {
    const root = document.body;
    if (!root) return [];

    const LEAF_SEL = 'p,h1,h2,h3,h4,h5,h6,li,dd,dt,td,th,caption,figcaption,blockquote,pre';
    const leafBlocks = Array.from(root.querySelectorAll(LEAF_SEL)).filter(visible);
    const covered = new Set();
    const blocks = [];

    for (const el of leafBlocks) {
      // 跳过嵌套在更深层已处理块中的元素(如 li 内的 p)
      const nodes = [];
      const w = document.createTreeWalker(el, NodeFilter.SHOW_TEXT);
      let anyOuter = false;
      while (w.nextNode()) {
        const n = w.currentNode;
        if (!n.nodeValue.trim()) continue;
        if (n.parentElement.closest(LEAF_SEL) !== el) { anyOuter = true; continue; }
        nodes.push(n);
      }
      if (anyOuter) continue; // 含嵌套块, 交给内层元素自己处理
      if (nodes.length) { blocks.push(nodes); nodes.forEach(n => covered.add(n)); }
    }

    // 兜底: 未被覆盖的散落文本节点, 按 parentElement 分组
    const strays = textNodesUnder(root).filter(n => !covered.has(n));
    const byParent = new Map();
    for (const n of strays) {
      const k = n.parentElement;
      if (!byParent.has(k)) byParent.set(k, []);
      byParent.get(k).push(n);
    }
    for (const group of byParent.values()) blocks.push(group);

    // 过滤太短的"块"(导航/按钮文字等), 但保留标题
    return blocks
      .filter(nodes => {
        const t = nodes.map(n => n.nodeValue).join('');
        const tag = nodes[0].parentElement.tagName;
        return t.trim().length >= 2 || /^H[1-6]$/.test(tag);
      })
      .filter(nodes => nodes.every(n => n.isConnected))
      .sort((a, b) => a[0].compareDocumentPosition(b[0]) & Node.DOCUMENT_POSITION_FOLLOWING ? -1 : 1);
  }

  // ---------- 句子切分 ----------
  function splitBlockIntoSegments(blockNodes) {
    // 计算每个节点的累计偏移
    const spans = []; // {node, start, end}
    let off = 0;
    const full = blockNodes.map(n => {
      const s = off; off += n.nodeValue.length;
      spans.push({ node: n, start: s, end: off });
      return n.nodeValue;
    }).join('');

    const segments = [];
    let segStart = 0;
    const pushSeg = (end) => {
      const raw = full.slice(segStart, end);
      if (raw.trim().length < 1) { segStart = end; return; }
      // 定位该句覆盖的 DOM 区间
      const ranges = [];
      for (const sp of spans) {
        if (sp.end <= segStart || sp.start >= end) continue;
        ranges.push({
          node: sp.node,
          start: Math.max(sp.start, segStart) - sp.start,
          end: Math.min(sp.end, end) - sp.start
        });
      }
      if (ranges.length) segments.push({ text: raw.trim(), ranges });
      segStart = end;
    };

    // 强句读: 。！？!?… 后必切(可吞紧跟的引号/括号)
    // 英文句点: 前后都不是数字且后随空白/中文/结尾才切, 避免 3.14 / e.g. 被切断
    // 弱句读: ，,：:；; 仅在超长时硬切
    const CLOSERS = /["'”’》\)）\]】」』]/;
    const CJK = /[\u4e00-\u9fff]/;
    for (let i = 0; i < full.length; i++) {
      const ch = full[i];
      if ('。！？!?…'.includes(ch)) {
        let end = i + 1;
        while (end < full.length && CLOSERS.test(full[end])) end++;
        pushSeg(end);
        i = end - 1;
      } else if (ch === '.') {
        const prev = full[i - 1], next = full[i + 1];
        if (!/\d/.test(prev || '') && !/\d/.test(next || '') &&
            (next === undefined || /\s/.test(next) || CJK.test(next))) {
          pushSeg(i + 1);
        }
      } else if ('，,：:；;'.includes(ch) && i - segStart >= 100) {
        pushSeg(i + 1); // 超长无强句读时在弱标点处硬切
      } else if (i - segStart >= 300) {
        pushSeg(i + 1); // 完全无标点的超长兜底
      }
    }
    if (segStart < full.length) pushSeg(full.length);
    return segments;
  }

  // ---------- 高亮 ----------
  function setHighlight(ranges) {
    clearHighlight();
    if (!ranges || !(window.CSS && 'highlights' in window.CSS)) {
      if (ranges && ranges[0]) {
        try {
          const r = document.createRange();
          r.setStart(ranges[0].node, ranges[0].start);
          r.setEnd(ranges[0].node, ranges[0].end);
          const sel = window.getSelection();
          sel.removeAllRanges(); sel.addRange(r);
        } catch (_) {}
      }
      return;
    }
    const hl = new window.Highlight();
    for (const rg of ranges) {
      try {
        const r = document.createRange();
        r.setStart(rg.node, rg.start);
        r.setEnd(rg.node, rg.end);
        hl.add(r);
      } catch (_) {}
    }
    window.CSS.highlights.set(HIGHLIGHT, hl);
  }
  function clearHighlight() {
    if (window.CSS && 'highlights' in window.CSS) window.CSS.highlights.delete(HIGHLIGHT);
    else window.getSelection()?.removeAllRanges();
  }

  function scrollToRanges(ranges) {
    try {
      const r = document.createRange();
      r.setStart(ranges[0].node, ranges[0].start);
      r.setEnd(ranges[0].node, ranges[0].end);
      const rect = r.getBoundingClientRect();
      const target = window.scrollY + rect.top - window.innerHeight * 0.35;
      window.scrollTo({ top: Math.max(0, target), behavior: 'smooth' });
    } catch (_) {}
  }

  // ---------- 播放引擎(音频在 offscreen document 播放, 规避网页自动播放限制) ----------
  class Reader {
    constructor(segments, startIdx) {
      this.segments = segments;
      this.idx = startIdx;
      this.paused = false;
      this.stopped = false;
      this.segmentActive = false; // 当前句音频已交付播放
      this.prefetch = new Map(); // idx -> Promise<{buffer,mime}>
    }

    start() {
      buildToolbar(this);
      this.play(this.idx);
    }

    prefetchSegment(i) {
      if (i >= this.segments.length || this.prefetch.has(i)) return;
      const p = chrome.runtime.sendMessage({ type: 'mra-tts', text: this.segments[i].text })
        .then(r => {
          if (!r.ok) throw new Error(r.error);
          return r;
        });
      this.prefetch.set(i, p);
      p.catch(() => this.prefetch.delete(i));
    }

    async play(i) {
      if (this.stopped) return;
      if (i >= this.segments.length) { stopSession(); return; }
      this.idx = i;
      const seg = this.segments[i];
      setHighlight(seg.ranges);
      scrollToRanges(seg.ranges);
      updateToolbar();

      this.prefetchSegment(i);
      this.prefetchSegment(i + 1);

      let data;
      try {
        data = await this.prefetch.get(i);
      } catch (e) {
        showToolbarError('TTS 服务连接失败: ' + e.message);
        this.stopped = true;
        return;
      }

      if (this.stopped || this.idx !== i) return;
      hideToolbarError();

      this.segmentActive = true;
      const r = await chrome.runtime.sendMessage({
        type: 'mra-play-audio', b64: data.b64, mime: data.mime
      }).catch(e => ({ ok: false, error: String(e) }));
      this.segmentActive = false;

      if (this.stopped || this.idx !== i) return;
      if (!r || !r.ok) {
        showToolbarError('播放失败: ' + ((r && r.error) || '无响应'));
        this.stopped = true;
        return;
      }
      if (r.ended) this.play(i + 1);
      // ended=false: 被 跳转/停止/新句 取代, 不推进
    }

    pause() {
      this.paused = true;
      chrome.runtime.sendMessage({ type: 'mra-audio-pause' }).catch(() => {});
      updateToolbar();
    }

    resume() {
      this.paused = false;
      updateToolbar();
      if (this.segmentActive) {
        chrome.runtime.sendMessage({ type: 'mra-audio-resume' }).catch(() => {});
      } else {
        this.play(this.idx);
      }
    }

    jump(delta) { this.goto(this.idx + delta); }

    goto(n) {
      n = Math.min(Math.max(0, n), this.segments.length - 1);
      chrome.runtime.sendMessage({ type: 'mra-audio-stop' }).catch(() => {}); // settle 当前播放
      this.paused = false;
      this.play(n);
    }

    stop() {
      this.stopped = true;
      chrome.runtime.sendMessage({ type: 'mra-audio-stop' }).catch(() => {});
      this.prefetch.clear();
    }
  }

  // ---------- 悬浮控制条 ----------
  let toolbarEl = null;
  const RATES = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];

  function buildToolbar(reader) {
    removeToolbar();
    const bar = document.createElement('div');
    bar.id = 'mra-toolbar';
    bar.innerHTML = `
      <button data-act="prev" title="上一句">⏮</button>
      <button data-act="playpause" title="暂停/继续">⏸</button>
      <button data-act="next" title="下一句">⏭</button>
      <button data-act="rate" title="语速">×<span id="mra-rate">1</span></button>
      <span id="mra-progress"></span>
      <button data-act="stop" title="停止">✕</button>`;
    bar.addEventListener('click', (e) => {
      const btn = e.target.closest('button');
      if (!btn || !session) return;
      switch (btn.dataset.act) {
        case 'prev': session.jump(-1); break;
        case 'next': session.jump(1); break;
        case 'stop': stopSession(); break;
        case 'rate': {
          const cur = RATES.indexOf(session._rate ?? 1.0);
          session._rate = RATES[(cur + 1 + RATES.length) % RATES.length];
          changeRate(session._rate);
          break;
        }
        case 'playpause':
          session.paused ? session.resume() : session.pause();
          break;
      }
    });
    document.documentElement.appendChild(bar);
    toolbarEl = bar;
  }

  function changeRate(rate) {
    if (!session) return;
    // 立即以新语速重发当前句(background 每次请求都读最新设置)
    session.prefetch.delete(session.idx);
    chrome.runtime.sendMessage({ type: 'mra-audio-stop' }).catch(() => {});
    session.play(session.idx);
    chrome.storage.sync.set({ rate });
  }

  function updateToolbar() {
    if (!toolbarEl || !session) return;
    toolbarEl.querySelector('[data-act="playpause"]').textContent = session.paused ? '▶' : '⏸';
    toolbarEl.querySelector('#mra-rate').textContent =
      String((session._rate ?? 1.0).toFixed(2)).replace(/0+$/, '').replace(/\.$/, '');
    toolbarEl.querySelector('#mra-progress').textContent =
      `${session.idx + 1}/${session.segments.length}`;
  }

  function showToolbarError(msg) {
    if (!toolbarEl) return;
    let el = toolbarEl.querySelector('#mra-error');
    if (!el) {
      el = document.createElement('span');
      el.id = 'mra-error';
      toolbarEl.appendChild(el);
    }
    el.textContent = msg;
  }

  function hideToolbarError() {
    toolbarEl?.querySelector('#mra-error')?.remove();
  }

  function removeToolbar() {
    document.getElementById('mra-toolbar')?.remove();
    toolbarEl = null;
  }

  // ---------- 会话管理 ----------
  async function start(fromIdx, matchText) {
    stopSession();
    const blocks = extractBlocks();
    const segments = blocks.flatMap(splitBlockIntoSegments);
    if (!segments.length) return;

    let idx = 0;
    if (matchText) {
      const found = segments.findIndex(s => s.text.includes(matchText));
      if (found >= 0) idx = found;
    }
    if (typeof fromIdx === 'number') idx = fromIdx;

    const { settings } = await getConfig();
    session = new Reader(segments, idx);
    session._rate = settings.rate;
    session.start();
  }

  function stopSession() {
    if (session) { session.stop(); session = null; }
    clearHighlight();
    removeToolbar();
  }

  // Alt+点击: 从点击处的句子开始朗读
  document.addEventListener('click', (e) => {
    if (!e.altKey || session) return;
    const segs = extractBlocks().flatMap(splitBlockIntoSegments);
    const x = e.clientX, y = e.clientY;
    const hit = segs.findIndex(s => s.ranges.some(r => {
      try {
        const rng = document.createRange();
        rng.setStart(r.node, r.start);
        rng.setEnd(r.node, r.end);
        const rect = rng.getBoundingClientRect();
        return x >= rect.left - 4 && x <= rect.right + 4 && y >= rect.top - 4 && y <= rect.bottom + 4;
      } catch (_) { return false; }
    }));
    start(hit >= 0 ? hit : undefined);
  }, true);

  // ---------- 消息入口 ----------
  chrome.runtime.onMessage.addListener((msg, _sender, sendResponse) => {
    switch (msg.type) {
      case 'mra-ping': sendResponse({ ok: true }); break;
      case 'mra-toggle':
        session ? stopSession() : start(undefined, window.getSelection()?.toString());
        sendResponse({ ok: true });
        break;
      case 'mra-start':
        start(undefined, msg.mode === 'selection' ? window.getSelection()?.toString() : undefined);
        sendResponse({ ok: true });
        break;
      default:
        return; // 不接管其它扩展消息
    }
    return true;
  });
})();
