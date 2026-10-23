const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const test = require('node:test');
const vm = require('node:vm');

const root = path.resolve(__dirname, '..');
const html = fs.readFileSync(path.join(root, 'web/index.html'), 'utf8');
const drawerScript = html.slice(html.indexOf("const drawer ="), html.indexOf('// ── Coach toast'));
const clickStart = html.indexOf('// Intercept ALL .md links');
const clickScript = html.slice(clickStart, html.indexOf('</script>', clickStart));

function element(attrs = {}) {
    const classes = new Set();
    return {
        attrs, listeners: {}, textContent: '', disabled: false,
        getAttribute(name) { return this.attrs[name]; },
        setAttribute(name, value) { this.attrs[name] = value; },
        removeAttribute(name) { delete this.attrs[name]; },
        addEventListener(name, callback) { this.listeners[name] = callback; },
        classList: {
            add(name) { classes.add(name); },
            remove(name) { classes.delete(name); },
            contains(name) { return classes.has(name); },
        },
    };
}

function workspace(baseURI = 'https://example.test/workshop/') {
    const elements = new Map();
    const documentListeners = {};
    const requests = [];
    const delays = new Map();
    const content = element();
    let anchors = [];
    let headings = [];
    let rendered = '';
    Object.defineProperty(content, 'innerHTML', {
        get() { return rendered; },
        set(value) {
            rendered = value;
            anchors = [...value.matchAll(/\[[^\]]*\]\(([^)\s]+)\)/g)]
                .map(match => element({ href: match[1] }));
            headings = [...value.matchAll(/^#{1,4} (.+)$/gm)]
                .map(match => ({ textContent: match[1] }));
        },
    });
    content.querySelectorAll = selector => selector === 'a[href]' ? anchors
        : selector === 'h1, h2, h3, h4' ? headings : [];
    content.querySelector = selector => {
        const heading = headings.find(item => `#${item.id}` === selector);
        return heading && { scrollIntoView() { content.scrolledTo = heading.id; } };
    };
    elements.set('drawer-content', content);
    const getElementById = id => {
        if (!elements.has(id)) elements.set(id, element());
        return elements.get(id);
    };
    getElementById('drawer').querySelector = () => ({ scrollTop: 0 });
    const context = vm.createContext({
        document: {
            baseURI,
            getElementById,
            body: { style: {} },
            addEventListener(name, callback) { documentListeners[name] = callback; },
        },
        URL, CSS: { escape: value => value },
        marked: { parse: value => value },
        fetch: async file => {
            requests.push(file);
            if (delays.has(file)) await delays.get(file);
            const filename = path.resolve(root, file);
            return {
                ok: fs.existsSync(filename), status: 404,
                text: async () => fs.readFileSync(filename, 'utf8'),
            };
        },
    });
    vm.runInContext(drawerScript + '\n' + clickScript, context);
    const settle = () => new Promise(resolve => setImmediate(resolve));
    return {
        elements, requests, content, settle,
        async open(file, fragment = '') {
            vm.runInContext(`openDrawer(${JSON.stringify(file)}, ${JSON.stringify(fragment)})`, context);
            await settle();
        },
        async follow(ending) {
            const anchor = anchors.find(item => item.attrs.href.endsWith(ending));
            assert.ok(anchor, `Missing link ${ending}`);
            let prevented = false;
            anchor.listeners.click({
                preventDefault() { prevented = true; },
                stopPropagation() {},
            });
            assert.ok(prevented);
            await settle();
        },
        clickDocument(href) {
            let prevented = false;
            const link = element({ href });
            documentListeners.click({
                target: { closest: () => link },
                preventDefault() { prevented = true; },
            });
            return prevented;
        },
        current() { return vm.runInContext('activeFiles[currentIdx].file', context); },
        delay(file) {
            let release;
            delays.set(file, new Promise(resolve => { release = resolve; }));
            return release;
        },
    };
}

function navigation() {
    const sample = element();
    const primary = element();
    const toggle = element();
    const summary = { focus() { this.focused = true; } };
    const listeners = {};
    sample.open = false;
    sample.contains = target => target === summary;
    sample.querySelector = () => summary;
    const context = vm.createContext({
        document: {
            getElementById: id => id === 'sampleNav' ? sample : primary,
            querySelector: () => toggle,
            addEventListener(name, callback) { listeners[name] = callback; },
        },
        window: {
            matchMedia: () => ({
                addEventListener(name, callback) { listeners.resize = callback; },
            }),
        },
    });
    vm.runInContext(html.slice(html.indexOf('const sampleNav ='), html.indexOf('// ── Active nav highlight')), context);
    return { sample, primary, toggle, summary, listeners };
}

test('sample selection closes both navigation layers and updates the mobile toggle', () => {
    const nav = navigation();
    nav.sample.open = true;
    nav.primary.classList.add('open');
    nav.primary.listeners.click({ target: { closest: () => ({ href: '#java-challenges' }) } });
    assert.equal(nav.sample.open, false);
    assert.equal(nav.primary.classList.contains('open'), false);
    assert.equal(nav.toggle.attrs['aria-expanded'], 'false');
});

test('sample navigation dismisses outside, restores focus on Escape, and resets on resize', () => {
    const nav = navigation();
    nav.sample.open = true;
    nav.listeners.click({ target: nav.summary });
    assert.equal(nav.sample.open, true);
    nav.listeners.click({ target: {} });
    assert.equal(nav.sample.open, false);
    nav.sample.open = true;
    let stopped = false;
    nav.listeners.keydown({ key: 'Escape', stopImmediatePropagation() { stopped = true; } });
    assert.equal(nav.sample.open, false);
    assert.equal(nav.summary.focused, true);
    assert.equal(stopped, true);
    nav.sample.open = true;
    nav.primary.classList.add('open');
    nav.listeners.resize();
    assert.equal(nav.sample.open, false);
    assert.equal(nav.primary.classList.contains('open'), false);
});

test('all seven rebuild milestones navigate without crossing into the CLI route', async () => {
    const site = workspace();
    await site.open('Student/rebuild/Challenge-00.md');
    assert.equal(site.elements.get('drawer-prev').disabled, true);
    for (let index = 1; index <= 6; index++) {
        site.elements.get('drawer-next').listeners.click();
        await site.settle();
        assert.equal(site.current(), `Student/rebuild/Challenge-0${index}.md`);
        assert.doesNotMatch(site.content.innerHTML, /Failed to load/);
        if (index <= 3) {
            const heading = site.content.innerHTML.match(/^# Challenge \d+: (.+)$/m)[1];
            assert.equal(site.elements.get('drawer-title').textContent, `Rebuild - ${heading}`);
        }
    }
    assert.equal(site.elements.get('drawer-next').disabled, true);
});

test('setup, supporting profiles, and challenge links switch groups correctly in previews', async () => {
    const site = workspace('https://example.test/workshop/previews/pr-42-abcd/');
    await site.open('Student/rebuild/Challenge-00.md');
    await site.follow('/Student/rebuild/setup.md');
    assert.equal(site.current(), 'Student/rebuild/setup.md');
    assert.equal(site.elements.get('drawer-kind').textContent, 'GUIDE');
    await site.follow('/Student/rebuild/supporting-skills.md');
    assert.equal(site.current(), 'Student/rebuild/supporting-skills.md');
    await site.follow('/Student/rebuild/Challenge-00.md');
    assert.equal(site.current(), 'Student/rebuild/Challenge-00.md');
    assert.ok(site.requests.every(file => !file.includes('previews/')));
});

test('sample architecture guide opens from preview navigation and links to the selected sample track', async () => {
    const site = workspace('https://example.test/workshop/previews/pr-42-abcd/');
    assert.equal(site.clickDocument('Student/sample-architecture.md'), true);
    await site.settle();
    assert.equal(site.current(), 'Student/sample-architecture.md');
    assert.equal(site.elements.get('drawer-kind').textContent, 'GUIDE');
    assert.equal(site.elements.get('drawer-title').textContent, 'Sample Architecture & Services');
    assert.match(site.content.innerHTML, /# Sample architecture & services/);
    await site.follow('/Student/net8/Challenge-03.md');
    assert.equal(site.current(), 'Student/net8/Challenge-03.md');
    assert.match(site.content.innerHTML, /# Challenge 03/);
});

test('relative source links with fragments open the actual local document', async () => {
    const site = workspace();
    const file = 'plugins/agentic-modernization/skills/cloud-architecture-diagram/references/REFERENCE.md';
    await site.open(file, '#source-and-asset-terms');
    assert.equal(site.current(), file);
    assert.equal(site.content.scrolledTo, 'source-and-asset-terms');
    await site.follow('/topology-patterns.md');
    assert.equal(site.current(), file.replace('REFERENCE.md', 'topology-patterns.md'));
    assert.doesNotMatch(site.content.innerHTML, /Failed to load/);
});

test('unregistered local guides do not silently fall back to README', async () => {
    const site = workspace();
    await site.open('CONTRIBUTING.md');
    assert.equal(site.current(), 'CONTRIBUTING.md');
    assert.match(site.content.innerHTML, /Modernization plugin and route content/);
    assert.equal(site.elements.get('drawer-prev').disabled, true);
    assert.equal(site.elements.get('drawer-next').disabled, true);
});

test('page interception preserves external markdown and handles local preview URLs', async () => {
    const site = workspace('https://example.test/workshop/previews/pr-42-abcd/');
    assert.equal(site.clickDocument('https://github.com/org/repo/blob/main/README.md'), false);
    assert.equal(site.clickDocument('#routes'), false);
    assert.equal(site.clickDocument('Student/rebuild/Challenge-03.md'), true);
    await site.settle();
    assert.equal(site.current(), 'Student/rebuild/Challenge-03.md');
});

test('a slow earlier fetch cannot overwrite the next selected milestone', async () => {
    const site = workspace();
    const release = site.delay('Student/rebuild/Challenge-00.md');
    await site.open('Student/rebuild/Challenge-00.md');
    await site.open('Student/rebuild/Challenge-01.md');
    assert.match(site.content.innerHTML, /# Challenge 01:/);
    release();
    await site.settle();
    assert.equal(site.current(), 'Student/rebuild/Challenge-01.md');
    assert.match(site.content.innerHTML, /# Challenge 01:/);
});

test('drawer route colors follow student, coach, demo, and setup documents', async () => {
    const site = workspace();
    for (const [file, route] of [
        ['Student/java/Challenge-00.md', 'refactor'],
        ['Student/dotnet/Challenge-00.md', 'refactor'],
        ['Student/net8/Challenge-00.md', 'refactor'],
        ['Student/customer/Challenge-00.md', 'refactor'],
        ['Student/rebuild/Challenge-00.md', 'rebuild'],
        ['Student/rebuild/setup.md', 'rebuild'],
        ['Coach/rebuild/facilitation-guide.md', 'rebuild'],
        ['Coach/dotnet/Solution-00.md', 'refactor'],
        ['Coach/demo/java/guide.md', 'refactor'],
        ['Student/sample-architecture.md', 'refactor'],
        ['README.md', undefined],
    ]) {
        await site.open(file);
        assert.equal(site.elements.get('drawer').attrs['data-route'], route, file);
    }
});

test('previous and next navigation update the drawer route and reset shared guides', async () => {
    const site = workspace();
    await site.open('Student/rebuild/setup.md');
    assert.equal(site.elements.get('drawer').attrs['data-route'], 'rebuild');
    site.elements.get('drawer-prev').listeners.click();
    await site.settle();
    assert.equal(site.current(), 'Student/sample-architecture.md');
    assert.equal(site.elements.get('drawer').attrs['data-route'], 'refactor');
    site.elements.get('drawer-next').listeners.click();
    await site.settle();
    assert.equal(site.elements.get('drawer').attrs['data-route'], 'rebuild');
    await site.open('Student/java/Challenge-00.md');
    site.elements.get('drawer-prev').listeners.click();
    await site.settle();
    assert.equal(site.current(), 'README.md');
    assert.equal(site.elements.get('drawer').attrs['data-route'], undefined);
    site.elements.get('drawer-next').listeners.click();
    await site.settle();
    assert.equal(site.elements.get('drawer').attrs['data-route'], 'refactor');
});
