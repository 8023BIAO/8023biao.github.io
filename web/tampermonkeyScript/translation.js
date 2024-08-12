
(function() {
	'use strict';

	try {
		//alert("All resources finished loading!");
		if (location.href.indexOf("csdn.net") > -1) {
			try {
				$(".article_content").removeAttr("style");
				$(".readall_box").remove();
				$("#btn-app").remove();
				$("[data-track-click]").removeAttr("data-track-click");
				$(document).off('click', '.container-blog a');
			} catch (err) {
				//alert(err);
			}
			try {
				csdn.copyright.init("", "", "");
			} catch (err) {}
		} else if (location.href.indexOf("jianshu.com") > -1) {
			try {
				document.getElementsByClassName("collapse-free-content")[0].removeAttribute("class");
				document.getElementsByClassName("collapse-tips")[0].removeAttribute("class");
			} catch (err) {
				//alert(err);
			}
		} else if (location.href.indexOf("iteye.com") > -1) {
			try {
 				document.getElementById("blog_content").removeAttribute("style");
 				document.getElementById("btn-readmore").parentNode.remove();
			} catch (err) {
				//alert(err);
			}
		} else if (location.href.indexOf("360doc.cn/article/") > -1) {
			try {
				$('#artcontentdiv').removeClass('article_maxh');
  				$('.article_showall').remove();
			} catch (err) {
				//alert(err);
			}
		} else if (location.href.indexOf("yq.aliyun.com/articles") > -1) {
			try {
				document.getElementById("btn-readmore").parentNode.parentNode.removeAttribute("style");
 				document.getElementById("btn-readmore").parentNode.remove();
			} catch (err) {
				//alert(err);
			}
		}else if (location.href.indexOf("zhidao.baidu.com/question/") > -1) {
			try {
				$(".w-detail-display-btn").remove();
				$(".w-detail-container.w-detail-index").removeAttr("style");
				$(".icon-bannerad").remove();
			} catch (err) {
				//alert(err);
			}
		}
	} catch (e) {
		alert(e);
	}


})();



// ==UserScript==
// @name       视频网HTML5播放小工具
// @description 三大功能 。启用HTML5播放；万能网页全屏；添加快捷键：快进、快退、暂停/播放、音量、下一集、切换(网页)全屏、上下帧、播放速度。支持视频站点：油管、TED、优.土、QQ、B站、西瓜视频、爱奇艺、A站、PPTV、芒果TV、咪咕视频、新浪、微博、网易[娱乐、云课堂、新闻]、搜狐、风行、百度云视频等；直播：斗鱼、YY、虎牙、龙珠、战旗。可增加自定义站点
// @homepage   https://bbs.kafan.cn/thread-2093014-1-1.html
// @include    https://*.qq.com/*
// @exclude    https://user.qzone.qq.com/*
// @include    https://www.weiyun.com/video_*
// @include    https://v.youku.com/v_show/id_*
// @include    https://vku.youku.com/live/*
// @include    https://video.tudou.com/v/*
// @include    https://www.iqiyi.com/*
// @include    https://live.bilibili.com/*
// @include    https://www.bilibili.com/*
// @include    https://www.ixigua.com/*
// @include    https://www.acfun.cn/*
// @include    http://v.pptv.com/show/*
// @include    https://v.pptv.com/show/*
// @include    https://www.miguvideo.com/*
// @include    https://tv.sohu.com/*
// @include    https://film.sohu.com/album/*
// @include    https://www.mgtv.com/*
// @version    1.8.1
// @include    https://pan.baidu.com/*
// @include    https://yun.baidu.com/*
// @include    https://*.163.com/*
// @include    https://*.icourse163.org/*
// @include    https://*.sina.com.cn/*
// @include    https://video.sina.cn/*
// @include    http://k.sina.*
// @include    https://k.sina.*
// @include    https://weibo.com/*
// @include    https://*.weibo.com/*
// @include    https://pan.baidu.com/*
// @include    https://yun.baidu.com/*
// @include    http://v.ifeng.com/*
// @include    https://v.ifeng.com/*
// @include    http://news.mtime.com/*
// @include    http://video.mtime.com/*
// @GM_info
// @include    https://www.youtube.com/watch?v=*
// @include    https://www.ted.com/talks/*
// @noframes
// @include    https://www.yy.com/*
// @include    https://www.huya.com/*
// @include    https://v.douyu.com/*
// @include    https://www.douyu.com/*
// @include    http://star.longzhu.com/*
// @include    https://star.longzhu.com/*
// @include    https://www.zhanqi.tv/*
// @run-at     document-start
// @include    */play*
// @include    *play/*
// @grant      unsafeWindow
// @grant      GM_addStyle
// @grant      GM_registerMenuCommand
// @grant      GM_setValue
// @grant      GM_getValue
// @namespace  https://greasyfork.org/users/7036
// ==/UserScript==

'use strict';
const w = unsafeWindow || window;
const { host, pathname: path } = location;
const d = document, find = [].find;
let v, _fp, _fs, by; // document.body
const observeOpt = {childList : true, subtree : true};
const noopFn = () => {};
const q = (css, p = d) => p.querySelector(css);
const delElem = e => e.remove();
const $$ = function(c, cb = delElem, doc = d) {
	if (!c || !c.length) return;
	if (typeof c === 'string') c = doc.querySelectorAll(c);
	if (!cb) return c;
	for (let e of c) if (e && cb(e)=== !1) break;
};
const gmFuncOfCheckMenu = (title, saveName, defaultVal = true) => {
	const r = GM_getValue(saveName, defaultVal);
	if (r) title = '√  '+ title;
	GM_registerMenuCommand(title, () => {
		GM_setValue(saveName, !r);
		location.reload();
	});
	return r;
};
const r1 = (regp, s) => regp.test(s) && RegExp.$1;
const log = console.log.bind(console, '%c脚本[%s] 反馈：%s\n%s', 'color:#c3c;font-size:1.5em',
	GM_info.script.name, GM_info.script.homepage);
const sleep = ms => new Promise(resolve => { setTimeout(resolve, ms) });
/*
const onceEvent = (ctx, eName) => new Promise(resolve => ctx.addEventListener(eName, resolve));
const promisify = (fn) => (...args) => new Promise((resolve, reject) => {
    args.push(resolve);
	fn.apply(this, args);
}); */
const hookAttachShadow = (cb) => {
	try {
		const _attachShadow = Element.prototype.attachShadow;
		Element.prototype.attachShadow = function(opt) {
			opt.mode = 'open';
			const shadowRoot = _attachShadow.call(this, opt);
			cb(shadowRoot);
			return shadowRoot;
		};
	} catch (e) {
		console.error('Hack attachShadow error', e);
	}
};
const getStyle = (o, s) => {
	if (o.style[s]) return o.style[s];
	if (getComputedStyle) {
		const x = getComputedStyle(o, '');
		s = s.replace(/([A-Z])/g,'-$1').toLowerCase();
		return x && x.getPropertyValue(s);
	}
};
const doClick = e => {
	if (typeof e === 'string') e = q(e);
	if (e) { e.click ? e.click() : e.dispatchEvent(new MouseEvent('click')) };
};
const clickDualButton = btn => { // 2合1 按钮
	!btn.nextSibling || getStyle(btn, 'display') !== 'none' ? doClick(btn) : doClick(btn.nextSibling);
};
const intervalQuery = (cb, condition, stop = true) => {
	const fn = typeof condition === 'string' ? q.bind(null, condition) : condition;
	const t = setInterval(() => {
		const r = fn();
		if (r) {
			stop && clearInterval(t);
			cb(r);
		}
	}, 300);
	return t;
};
const goNextMV = () => {
	const s = location.pathname;
	const m = s.match(/(\d+)(\D*)$/);
	const d = +m[1] + 1;
	location.assign(s.slice(0, m.index) + d + m[2]);
};
const firefoxVer = r1(/Firefox\/(\d+)/, navigator.userAgent);
const isEdge = / Edge?\//.test(navigator.userAgent);
const fakeUA = ua => Object.defineProperty(navigator, 'userAgent', {
	value: ua,
	writable: false,
	configurable: false,
	enumerable: true
});
const getMainDomain = host => {
	const a = host.split('.');
	let i = a.length - 2;
	if (/^(com?|cc|tv|net|org|gov|edu)$/.test(a[i])) i--;
	return a[i];
};
const ua_chrome = 'Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/66.0.3626.121 Safari/537.36';

class FullScreen {
	constructor(e) {
		let fn = d.exitFullscreen || d.webkitExitFullscreen || d.mozCancelFullScreen || d.msExitFullscreen || noopFn;
		this.exit = fn.bind(d);
		fn = e.requestFullscreen || e.webkitRequestFullScreen || e.mozRequestFullScreen || e.msRequestFullScreen || noopFn;
		this.enter = fn.bind(e);
	}

	static isFull() {
		return !!(d.fullscreen || d.webkitIsFullScreen || d.mozFullScreen ||
		d.fullscreenElement || d.webkitFullscreenElement || d.mozFullScreenElement);
	}

	toggle() {
		FullScreen.isFull() ? this.exit() : this.enter();
	}
}

//万能网页全屏, 参考了：https://github.com/gooyie/ykh5p
class FullPage {
	constructor(container, onSwitch) {
		this._isFull = !1;
		this._onSwitch = onSwitch;
		this.container = container || FullPage.getPlayerContainer(v, true);
		GM_addStyle(
			`.gm-fp-body .gm-fp-zTop {
				position: relative !important;
				z-index: 2147483647 !important;
			}
			.gm-fp-wrapper, .gm-fp-body{ overflow:hidden !important; }
			.gm-fp-wrapper .gm-fp-innerBox {
				width: 100% !important;
				height: 100% !important;
			}
			.gm-fp-wrapper {
				display: block !important;
				position: fixed !important;
				width: 100% !important;
				height: 100% !important;
				top: 0 !important;
				left: 0 !important;
				background: #000 !important;
				z-index: 2147483647 !important;
			}`
		);
	}
	static getPlayerContainer(video, isAddClass) {
		let e = video, p = e.parentNode;
		const { clientWidth: wid, clientHeight: h } = e;
		do {
			isAddClass && e.classList.add('gm-fp-innerBox');
			e = p;
			p = e.parentNode;
		} while (e.nodeName == 'DIV' && p.clientWidth-wid < 5 && p.clientHeight-h < 5);
		//e 为返回值，在此之后不能变了
		while (p !== by) {
			p.nodeType == 1 && isAddClass && p.classList.add('gm-fp-zTop');
			p = p.parentNode || p.host;
		}
		return e;
	}
	static isFull(e) {
		return w.innerWidth - e.clientWidth < 5 && w.innerHeight - e.clientHeight < 5;
	}
	toggle() {
		const cb = this._onSwitch;
		if (!this._isFull && cb) cb(true);
		by.classList.toggle('gm-fp-body');
		this.container.classList.toggle('gm-fp-wrapper');
		this._isFull = !this._isFull;
		if (!this._isFull && cb) setTimeout(cb, 199, !1);
	}
}

const u = getMainDomain(host);
const events = {
	on(name, fn) {
		this[name] = fn;
	},
	undo(name) {
		delete this[name];
	},
	handle(name, ...a) {
		return this[name] && this[name].apply(this, a);
	}
};
const app = {
	isLive: !1,
	disableDBLClick: !1,
	multipleV: !1, //多视频页面
	isNumURL: !1, //网址数字分集
	disableKeys: [],
	shellEvent() {
		const fn = ev => {
			ev.stopPropagation();
			ev.preventDefault();
			_fp ? _fp.toggle() : clickDualButton(this.btnFP);
		};
		this.mvShell.addEventListener('mousedown', ev => {
			this.checkMV();
			if (!this.isLive && 1==ev.button) {
				ev.stopPropagation();
				v.currentTime += 5;
			}
		});
		!this.disableDBLClick && this.mvShell.addEventListener('dblclick',fn);
	},
	setShell() {
		const e = this.getDPlayer() || this.getVjsPlayer() ||
			(this.shellCSS && q(this.shellCSS)) || FullPage.getPlayerContainer(v, !1);
		if (e && this.mvShell != e) {
			this.mvShell = e;
			this.shellEvent();
		}
	},
	checkMV() {
		if (this.vList) {
			const e = this.findMV();
			if (e != v) {
				v = e;
				this.btnPlay = this.btnNext = this.btnFP = this.btnFS = _fs = _fp = null;
				if (!this.isLive) {
					v.playbackRate = localStorage.mvPlayRate || 1;
					v.addEventListener('ratechange', ev => {
						localStorage.mvPlayRate = v.playbackRate;
					});
				}
				this.setShell();
			}
		}
		this.checkUI();
		return v;
	},
	getDPlayer() {
		const e = v.closest('.dplayer');
		if (e) {
			this.btnFP = q('.dplayer-full-in-icon > span', e);
			this.btnFS = q('.dplayer-full-icon', e);
			e.closest('body > *').classList.add('gm-dp-zTop');
		}
		return e;
	},
	getVjsPlayer() {
		const e = v.closest('.video-js');
		if (e) {
			this.btnFS = q('.vjs-control-bar > button.vjs-button:nth-last-of-type(1)');
			this.webfullCSS = '.vjs-control-bar > button.vjs-button[title$="全屏"]:nth-last-of-type(2)';
		}
		return e;
	},
	hotKey(e) {
		const t = e.target;
		if (e.ctrlKey || e.altKey || t.contentEditable=='true' ||
			/INPUT|TEXTAREA|SELECT/.test(t.nodeName)) return;
		if (e.shiftKey && ![13,37,39].includes(e.keyCode)) return;
		if (this.disableKeys.includes(e.keyCode)) return;
		if (this.isLive && [37,39,78,88,67,90].includes(e.keyCode)) return;
		if (!this.checkMV()) return;
		if (events.handle('keydown', e)) return;
		if (!e.shiftKey && this.mvShell && this.mvShell.contains(t) && [32,37,39].includes(e.keyCode)) return;
		let n;
		switch (e.keyCode) {
		case 32: //space
			if (this.btnPlay) clickDualButton(this.btnPlay);
			else v.paused ? v.play() : v.pause();
			e.preventDefault();
			break;
		case 37: n = e.shiftKey ? -20 : -5; //left  快退5秒,shift加速
		//right  快进5秒,shift加速
		case 39: n = n || (e.shiftKey ? 20 : 5);
			v.currentTime += n;
			break;
		case 78: // N 下一首
			if (this.btnNext) doClick(this.btnNext);
			else if (this.isNumURL) goNextMV();
			break;
		case 38: n = 0.1; //加音量
		case 40: n = n || -0.1; //降音量
			n += v.volume;
			if (0 <= n && n <= 1) v.volume = +n.toFixed(1);
			e.preventDefault();
			break;
		case 13: //回车键。 全屏
			if (e.shiftKey) {
				_fp ? _fp.toggle() : clickDualButton(this.btnFP);
			} else {
				_fs ? _fs.toggle() : clickDualButton(this.btnFS);
			}
			break;
		case 27: //esc
			if (FullScreen.isFull()) {
				_fs ? _fs.exit() : clickDualButton(this.btnFS);
			} else if (FullPage.isFull(v)) {
				_fp ? _fp.toggle() : clickDualButton(this.btnFP);
			}
			break;
		case 67: n = 0.1; //按键C：加速播放 +0.1
		case 88: n = n || -0.1; //按键X：减速播放 -0.1
			n += v.playbackRate;
			if (0 < n && n <= 16) v.playbackRate = +n.toFixed(2);
			break;
		case 90: //按键Z：正常速度播放
			v.playbackRate = 1;
			break;
		case 70: n = 0.03; //按键F：下一帧
		case 68: n = n || -0.03; //按键D：上一帧
			v.currentTime += n;
			v.pause();
			break;
		default: return;
		}
		e.stopPropagation();
	},
	checkUI() {
		if (this.webfullCSS && !this.btnFP) this.btnFP = q(this.webfullCSS);
		if (this.btnFP) _fp = null;
		else if (!_fp) _fp = new FullPage(this.mvShell, this.switchFP);

		if (this.fullCSS && !this.btnFS) this.btnFS = q(this.fullCSS);
		if (this.btnFS) _fs = null;
		else if (!_fs) _fs = new FullScreen(v);

		if (this.nextCSS && !this.btnNext) this.btnNext = q(this.nextCSS);
		if (this.playCSS && !this.btnPlay) this.btnPlay = q(this.playCSS);
	},
	switchFP(toFull) {
		if (toFull) {
			for (let e of this.vSet) this.viewObserver.unobserve(e);
		} else {
			for (let e of this.vList) this.viewObserver.observe(e);
		}
	},
	onGrowVList() {
		if (this.vList.length == this.vCount) return;
		if (this.viewObserver) {
			for (let e of this.vList) {
				if (!this.vSet.has(e)) this.viewObserver.observe(e);
			}
		} else {
			const config = {
				rootMargin: '0px',
				threshold: 0.9
			};
			this.viewObserver = new IntersectionObserver(this.onIntersection.bind(this), config);
			for (let e of this.vList) this.viewObserver.observe(e);
		}
		this.vSet = new Set(this.vList);
		this.vCount = this.vList.length;
	},
	onIntersection(entries) {
		if (this.vList.length < 2) return;
		const entry = find.call(entries, k => k.isIntersecting);
		if (!entry || v == entry.target) return;
		v = entry.target;
		_fs = new FullScreen(v);
		_fp = new FullPage(null, this.switchFP);
		events.handle('switchMV');
	},
	bindEvent() {
		$$(this.adsCSS);
		by = d.body;
		log('bind event\n', v);
		events.handle('foundMV');
		if (!this.isLive) {
			v.playbackRate = localStorage.mvPlayRate || 1;
			v.addEventListener('ratechange', ev => {
				localStorage.mvPlayRate = v.playbackRate;
			});
		}
		const fn = ev => {
			events.handle('canplay');
			v.removeEventListener('canplaythrough', fn);
		};
		v.addEventListener('canplaythrough', fn);
		by.addEventListener('keydown', this.hotKey.bind(this));

		this.mvShell ? this.shellEvent() : this.setShell();
		this.checkUI();
		if (this.multipleV) {
			new MutationObserver(this.onGrowVList.bind(this)).observe(by, observeOpt);
			this.vCount = 0;
			this.onGrowVList();
		}
	},
	init() {
		this.switchFP = this.multipleV ? this.switchFP.bind(this) : null;
		this.vList = d.getElementsByTagName('video');
		const fn = e => this.cssMV ? e.matches(this.cssMV) : e.offsetWidth > 9;
		this.findMV = find.bind(this.vList, fn);
		const timer = intervalQuery(e => {
			v = e;
			this.bindEvent();
		}, this.findMV);

		hookAttachShadow(async shadowRoot => {
			await sleep(600);
			events.handle('addShadowRoot', shadowRoot);
			if (v) return;
			if (v = q('video', shadowRoot)) {
				log('Found MV in ShadowRoot\n', v, shadowRoot);
				if (!this.shellCSS) this.mvShell = shadowRoot.host;
				clearInterval(timer);
				this.bindEvent();

				this.vList = null;
				this.findMV = noopFn;
			}
		});
	}
};

let router = {
	ted() {
		app.fullCSS = 'button[title="Enter Fullscreen"]';
		app.playCSS = 'button[title="play video"]';
		if (!gmFuncOfCheckMenu('TED强制高清', 'ted_forceHD')) return;
		const getHDSource = async () => {
			const pn = r1(/^(\/talks\/\w+)/, path);
			const resp = await fetch(pn + '/metadata.json');
			const data = await resp.json();
			return data.talks[0].downloads.nativeDownloads.high;
		};
		const check = async (rs) => {
			if (!v.src || v.src.startsWith('http')) return;
			$$(app.vList, e => { e.removeAttribute('src') }); // 取消多余的媒体资源请求
			try {
				v.src = await getHDSource();
			} catch(ex) {
				console.error(ex);
			}
		};
		events.on('foundMV', () => {
			new MutationObserver(check).observe(v, {
				attributes: true,
				attributeFilter: ['src']
			});
			check();
		});
	},
	youtube() {
		app.playCSS = 'button.ytp-play-button';
		app.fullCSS = 'button.ytp-fullscreen-button';
		app.shellCSS = '#player';
		app.disableKeys = [32,70];
		events.on('keydown', ev => {
			switch (ev.keyCode) {
			case 69: //E，替换F键
				v.currentTime += 0.03;
				v.pause();
				return true;
			}
		});
	},
	qq() {
		app.disableKeys = [32];
		app.nextCSS = '.txp_btn_next';
		app.webfullCSS = '.txp_btn_fake';
		app.fullCSS = '.txp_btn_fullscreen';
	},
	youku() {
		events.on('keydown', ev => {
			switch (ev.keyCode) {
			case 32: //空格
				ev.preventDefault();
				v.paused ? v.play() : v.pause();
				return true;
			}
		});
		if (host.startsWith('vku.')) {
			events.on('canplay', () => {
				app.isLive = !q('.spv_progress');
			});
			app.fullCSS = '.live_icon_full';
		} else {
			events.on('foundMV',() => {
				by.addEventListener('keyup', e => e.stopPropagation());
			});
			app.shellCSS = '#ykPlayer';
			app.webfullCSS = '.control-webfullscreen-icon';
			app.fullCSS = '.control-fullscreen-icon';
			app.nextCSS = 'span.icon-next';
		}
	},
	bilibili() {
		app.isLive = host.startsWith('live.');
		if (app.isLive) return;
		const isSquirtle = path.startsWith('/bangumi');
		if (!isSquirtle) app.disableKeys = [32];
		app.shellCSS = isSquirtle ? '#bilibili-player' : '.player';
		app.nextCSS = isSquirtle ? '.squirtle-video-next' : '.bilibili-player-video-btn-next'; 
		app.webfullCSS = isSquirtle ? '.squirtle-video-pagefullscreen' : '.bilibili-player-video-web-fullscreen'; 
		app.fullCSS = isSquirtle ? '.squirtle-video-fullscreen' : '.bilibili-player-video-btn-fullscreen';
		const danmu = gmFuncOfCheckMenu('弹幕', 'bili_danmu');
		const danmuCSS = isSquirtle ? '.bpx-player-dm-switch input' : '.bilibili-player-video-danmaku-switch input';
		events.on('canplay', () => {
			intervalQuery(e => {if (e.checked != danmu) e.click()}, danmuCSS);
		});
		const fn = async (ev) => {
			events.canplay();
			app.btnFS = app.btnFP = app.mvShell = v = null;
			await sleep(300);
			app.mvShell = q(app.shellCSS);
		};

		const fName= isSquirtle ? 'replaceState' : 'pushState';
		const rawFn = history[fName]; //二方法不触发onpopstate事件
		history[fName] = function(...args) {
			rawFn.apply(this, args);
			fn();
		};
		w.addEventListener("pageshow", fn);
		w.addEventListener("popstate", fn);
	},
	iqiyi() {
		app.fullCSS = '.iqp-btn-fullscreen';
		app.webfullCSS = '.iqp-btn-webscreen';
		app.nextCSS = '.iqp-btn-next';
	},
	pptv() {
		app.fullCSS = '.w-zoom-container > div';
		app.webfullCSS = '.w-expand-container > div';
		app.nextCSS = '.w-next';
	},
	mgtv() {
		app.fullCSS = 'mango-screen';
		app.webfullCSS = 'mango-webscreen > a';
		app.nextCSS = 'mango-control-playnext-btn';
	},
	ixigua() {
		app.fullCSS = '.xgplayer-fullscreen';
		app.webfullCSS = '.xgplayer-cssfullscreen';
		app.nextCSS = '.xgplayer-playNext';
		events.on('foundMV', () => {
			v.addEventListener('keydown', app.hotKey.bind(app));
		});
	},
	miguvideo() {
		app.playCSS = '.play-btn';
		app.nextCSS = '.next-btn';
	},
	weibo() {
		app.multipleV = path.startsWith('/u/');
	},
	acfun() {
		app.nextCSS = '.btn-next-part .control-btn';
		app.webfullCSS = '.fullscreen-web';
		app.fullCSS = '.fullscreen-screen';
	},
	['163']() {
		app.multipleV = host.startsWith('news.');
		GM_addStyle('div.video,video{max-height: 100% !important;}');
		return host.split('.').length > 3;
	},
	sohu() {
		app.nextCSS = 'li.on[data-vid]+li a';
		app.fullCSS = '.x-fullscreen-btn';
		app.webfullCSS = '.x-pagefs-btn';
	},
	fun() {
		app.nextCSS = '.btn-item.btn-next';
	},
	le() {
		events.canplay = events.foundMV = ev => {
			if (v.offsetWidth>9) return;
			const ss = v.attributes;
			for (let i=ss.length - 1;i>=0;i--) if (v.getAttribute(ss[i].name) === void 0){
				v.removeAttribute(ss[i].name);
				break;
			}
		};
		const rawFn = history.pushState;
		history.pushState = function(...args) {
			rawFn.apply(this, args);
			setTimeout(events.foundMV, 1e3);
		};
	},
	agefans() {
		events.on('keydown', ev => {
			switch (ev.keyCode) {
			case 78: //N
				location.href = location.href.replace(/\d+$/, s => ++s);
				return true;
			}
		});
	},
	dililitv() {
		app.nextCSS = `a[href="${path}"]+a`;
		GM_addStyle('.dplayer-loaded{ background-color:orange !important; }');
	}
};
// www.dililitv.cc,www.hmtv.me,imeiju.io,www.lzvod.net
router.lzvod = router.hmtv = router.imeiju = router.dililitv;

if (!router[u]) { //直播站点
	router = {
		douyu() {
			app.adsCSS = 'a[href*="wan.douyu.com"]';
			app.isLive = !host.startsWith('v.');
			if (app.isLive) {
				app.cssMV = '.layout-Player video';
				app.webfullCSS = 'div[class|=wfs]';
				app.fullCSS = 'div[class|=fs]';
				app.playCSS = 'div[class|=play]';
				path != '/' && events.on('foundMV', () => {
					q('#js-player-aside-state').checked = true;
				});
			} else events.on('addShadowRoot', function(r) {
				if (r.host.matches('#demandcontroller-bar')) {
					app.btnFP = q('.ControllerBar-PageFull', r);
					app.btnFS = q('.ControllerBar-WindowFull', r);
					this.undo('addShadowRoot');
				}
			});
		},
		yy() {
			app.isLive = !path.startsWith('/x/');
			if (app.isLive) {
				app.fullCSS = '.yc__fullscreen-btn';
				app.webfullCSS = '.yc__cinema-mode-btn';
				app.playCSS = '.yc__play-btn';
			}
		},
		huya() {
			if (firefoxVer && firefoxVer < 57) return true;
			app.disableDBLClick = !0;
			app.webfullCSS = '.player-fullpage-btn';
			app.fullCSS = '.player-fullscreen-btn';
			app.playCSS = '#player-btn';
			app.adsCSS = '#player-subscribe-wap,#wrap-income';
			intervalQuery(doClick, '.login-tips-close');
			localStorage['sidebar/ads'] = '{}';
			localStorage['sidebar/state'] = 0;
			localStorage.TT_ROOM_SHIELD_CFG_0_ = '{"10000":1,"20001":1,"20002":1,"20003":1,"30000":1}';
		},
		longzhu() {
			app.fullCSS = 'a.ya-screen-btn';
		},
		zhanqi() {
			localStorage.lastPlayer = 'h5';
			app.fullCSS = '.video-fullscreen';
		}
	};
	if (router[u]) {
		app.isLive = app.isLive || !host.startsWith('v.');
		(!w.chrome || isEdge) && fakeUA(ua_chrome);
	}
}

Reflect.defineProperty(navigator, 'plugins', {
	get() { return { length: 0 } }
});
GM_registerMenuCommand('脚本功能快捷键表' , alert.bind(w,
`双击：切换网页全屏（部分站点有效）
鼠标中键：快进5秒

左右方向键：快退、快进5秒; +shift: 20秒
上下方向键：音量调节   ESC：退出（网页）全屏
空格键：暂停/播放      N：播放下一集
回车键：切换全屏; +shift: 切换网页全屏
C：加速0.1倍播放       X：减速0.1倍播放       Z：正常速度播放
D：上一帧     F：下一帧(youtube.com用E键)`
));
if (!router[u] || !router[u]()) app.init();
if (!router[u] && !app.isNumURL) app.isNumURL = /[_\W]\d+(\/|\.[a-z]{3,8})?$/.test(path);



