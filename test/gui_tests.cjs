'use strict';

// Run with Node.js: node test/gui_tests.cjs
// Executes the real inline script with a small DOM model; no browser packages needed.
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');

class Element {
    constructor(tag = 'div') {
        this.tagName = tag;
        this.children = [];
        this.handlers = {};
        this.style = {};
        this.value = '';
        this.className = '';
        this.textContent = '';
        this.classList = { add() {}, remove() {} };
    }
    set innerHTML(value) {
        assert.ok(!value.includes('<img') && !value.includes('<script'), 'User markup must stay text');
        this.children = [];
    }
    setAttribute(name, value) { this[name] = value; }
    addEventListener(type, handler) { this.handlers[type] = handler; }
    appendChild(child) { child.parent = this; this.children.push(child); return child; }
    querySelectorAll(selector) {
        return this.children.filter(child => selector === '.queue-item' && child.className.includes('queue-item'));
    }
    remove() {
        if (this.parent) this.parent.children = this.parent.children.filter(child => child !== this);
    }
}

const elements = new Map();
const element = id => {
    if (!elements.has(id)) elements.set(id, new Element());
    return elements.get(id);
};
const alerts = [];
const context = vm.createContext({
    document: {
        getElementById: element,
        createElement: tag => new Element(tag),
        createElementNS: (_ns, tag) => new Element(tag),
        querySelectorAll: () => [],
        querySelector: () => null
    },
    window: { addEventListener() {} },
    alert: value => alerts.push(value),
    setInterval: () => 1,
    clearInterval() {},
    console
});
const html = fs.readFileSync(path.join(__dirname, '..', 'Giao_dien_truc_quan.html'), 'utf8');
const script = html.match(/<script>([\s\S]*?)<\/script>/);
assert.ok(script, 'Inline simulation script exists');
vm.runInContext(script[1], context, { timeout: 1000 });

const run = source => vm.runInContext(source, context, { timeout: 1000 });
const plain = expression => JSON.parse(run(`JSON.stringify(${expression})`));
const input = value => { context.fixture = value; return run('parseTreeInput(fixture)'); };
const check = value => { context.fixture = value; return run('validateTree(fixture)'); };
const node = (id, val, trai = 0, phai = 0) => ({ id, val, trai, phai });
const chain = n => ({ goc: 1, nut: Array.from({ length: n }, (_, i) => node(i + 1, i, 0, i + 1 < n ? i + 2 : 0)) });
const click = id => element(id).handlers.click();
let count = 0;
function test(name, fn) {
    fn();
    count++;
    console.log(`GUI${String(count).padStart(2, '0')} PASS ${name}`);
}

test('two assignment examples', () => {
    for (const [sample, expected] of [[1, [[10], [20, 30], [40]]], [2, [[8]]]]) {
        run(`initSimulation(SAMPLES[${sample}]); while (!state.isFinished) stepSimulation()`);
        assert.deepEqual(plain('state.cac_muc'), expected);
    }
});
test('empty tree text is accepted', () => {
    input('goc: 0; nut: []');
    assert.deepEqual(plain('validateTree(fixture.startsWith("{") ? JSON.parse(fixture) : parseTreeInput(fixture))'), { goc: 0, nut: [] });
});
test('JSON gia_tri alias and shuffled IDs', () => {
    const parsed = input('{"goc":2,"nut":[{"id":1,"gia_tri":"lá","trai":0,"phai":0},{"id":2,"gia_tri":3.5,"trai":1,"phai":0}]}');
    assert.equal(parsed.nut[0].val, 'lá');
    assert.equal(parsed.goc, 2);
});
test('quoted strings with commas, spaces and quotes round trip', () => {
    context.fixture = { goc: 1, nut: [node(1, 'a, b ("c") [d]')] };
    assert.deepEqual(plain('parseTreeInput(formatTreeToText(fixture))'), context.fixture);
});
test('reject cycle instead of recursing', () => {
    assert.throws(() => input('goc: 1; nut: (1,10,2,0),(2,20,1,0)'));
});
test('reject disconnected cycle', () => {
    assert.throws(() => check({ goc: 1, nut: [node(1, 1), node(2, 2, 3), node(3, 3, 2)] }));
});
test('reject duplicate IDs', () => {
    assert.throws(() => check({ goc: 1, nut: [node(1, 1), node(1, 2)] }));
});
test('reject child referenced by two parents', () => {
    assert.throws(() => check({ goc: 1, nut: [node(1, 1, 2, 3), node(2, 2, 3), node(3, 3)] }));
});
test('reject repeated left/right child', () => {
    assert.throws(() => check({ goc: 1, nut: [node(1, 1, 2, 2), node(2, 2)] }));
});
test('reject out of range and fractional references', () => {
    for (const child of [-1, 2, 0.5]) assert.throws(() => check({ goc: 1, nut: [node(1, 1, child)] }));
});
test('reject root type and range errors', () => {
    for (const goc of [0, 2, 1.5, '1', true]) assert.throws(() => check({ goc, nut: [node(1, 1)] }));
    assert.throws(() => check({ goc: 1, nut: [] }));
});
test('100 nodes allowed and 101 rejected', () => {
    assert.equal(check(chain(100)).nut.length, 100);
    assert.throws(() => check(chain(101)));
});
test('reject nonfinite and non scalar values', () => {
    for (const value of [Infinity, NaN, null, {}, [], true]) {
        assert.throws(() => check({ goc: 1, nut: [node(1, value)] }));
    }
    assert.throws(() => input('goc: 1; nut: (1,1e999,0,0)'));
});
test('reject malformed tuples and trailing garbage', () => {
    for (const text of ['goc: 1; nut: (1,10,0,0) junk', 'goc: 1; nut: (1,10,0,0),(2,20,-1,)',
        'goc: 1; nut: (1,10,0,0),', 'goc: 0; nut:', 'goc: -1; nut: []']) {
        assert.throws(() => input(text), text);
    }
});
test('parse valid signed integers and finite decimal values', () => {
    const parsed = input('goc=1; nut=[(1, -1.25e2, 2, 0), (2, "leaf", 0, 0)]');
    assert.equal(parsed.nut[0].val, -125);
});
test('invalid load preserves tree and traversal state', () => {
    run('initSimulation(SAMPLES[1]); stepSimulation()');
    const before = plain('({tree: currentTree, levels: state.cac_muc, head: state.queueHead})');
    element('custom-input').value = 'goc: 1; nut: (1,10,1,0)';
    click('btn-load-custom');
    assert.deepEqual(plain('({tree: currentTree, levels: state.cac_muc, head: state.queueHead})'), before);
    assert.ok(alerts.at(-1).startsWith('Không thể nạp cây:'));
});
test('reject occupied child insertion without losing old branch', () => {
    run('initSimulation(SAMPLES[1])');
    const before = plain('currentTree');
    element('new-node-val').value = '99';
    element('parent-node-select').value = '1';
    element('child-pos-select').value = 'trai';
    click('btn-add-single-node');
    assert.deepEqual(plain('currentTree'), before);
    assert.ok(alerts.at(-1).includes('đã có nút con'));
});
test('insert into empty child keeps all nodes reachable', () => {
    element('parent-node-select').value = '3';
    element('child-pos-select').value = 'phai';
    click('btn-add-single-node');
    run('while (!state.isFinished) stepSimulation()');
    assert.deepEqual(plain('state.cac_muc'), [[10], [20, 30], [40, 99]]);
});
test('reset restarts the custom tree', () => {
    const before = plain('currentTree');
    element('sample-select').value = '2';
    click('btn-reset');
    assert.deepEqual(plain('currentTree'), before);
    assert.equal(run('state.queueHead'), 0);
    assert.deepEqual(plain('state.cac_muc'), []);
});
test('node 101 insertion is rejected', () => {
    context.fixture = chain(100);
    run('initSimulation(fixture)');
    element('new-node-val').value = '101';
    element('parent-node-select').value = '100';
    element('child-pos-select').value = 'phai';
    click('btn-add-single-node');
    assert.equal(run('currentTree.nut.length'), 100);
    assert.ok(alerts.at(-1).includes('100 nút'));
});
test('strings render as text and have no numeric average', () => {
    context.fixture = { goc: 1, nut: [node(1, '<img src=x onerror=alert(1)>')] };
    run('initSimulation(fixture); stepSimulation()');
    const cells = element('level-table-body').children[0].children;
    assert.equal(cells[1].textContent, '[<img src=x onerror=alert(1)>]');
    assert.equal(cells[3].textContent, 'Không áp dụng');
});
test('FIFO cursor and queue maximum on full and chain trees', () => {
    run('initSimulation(SAMPLES[3]); while (!state.isFinished) stepSimulation()');
    assert.deepEqual(plain('state.cac_muc'), [[1], [2, 3], [4, 5, 6, 7]]);
    assert.equal(run('state.maxQueueLen'), 4);
    assert.equal(run('state.queueHead'), 7);
    context.fixture = chain(31);
    run('initSimulation(fixture); while (!state.isFinished) stepSimulation()');
    assert.equal(run('state.maxQueueLen'), 1);
    assert.equal(run('state.queueHead'), 31);
});
test('tie chooses first level', () => {
    run('initSimulation(SAMPLES[4]); while (!state.isFinished) stepSimulation()');
    assert.equal(element('stat-max-w').textContent, 2);
    assert.equal(element('stat-level').textContent, 1);
});
test('empty tree can load via UI then create a root', () => {
    element('custom-input').value = 'goc: 0; nut: []';
    click('btn-load-custom');
    assert.equal(run('state.isFinished'), true);
    element('new-node-val').value = '8';
    click('btn-add-single-node');
    assert.deepEqual(plain('currentTree'), { goc: 1, nut: [node(1, 8)] });
});

console.log(`GUI TEST SUMMARY: ${count}/${count} independent cases PASS (DOM model; browser layout not tested).`);
