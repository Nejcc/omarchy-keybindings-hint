import { test } from 'node:test'
import assert from 'node:assert/strict'
import { readFileSync, existsSync } from 'node:fs'
import { resolve, sep } from 'node:path'
import { fileURLToPath } from 'node:url'
import { spawnSync } from 'node:child_process'
import vm from 'node:vm'

const root = resolve(fileURLToPath(new URL('..', import.meta.url)))
test('package: manifest, entrypoints, JavaScript and QML syntax', () => {
  const manifest = JSON.parse(readFileSync(resolve(root, 'manifest.json'), 'utf8'))
  assert.equal(manifest.schemaVersion, 1)
  assert.equal(manifest.id, 'nejcc.keybindings-hint')
  assert.match(manifest.version, /^\d+\.\d+\.\d+$/)
  assert.deepEqual(manifest.kinds, ['overlay'])
  assert.deepEqual(Object.keys(manifest.entryPoints), ['overlay'])
  for (const file of Object.values(manifest.entryPoints)) {
    const path = resolve(root, file)
    assert.ok(path.startsWith(root + sep))
    assert.ok(existsSync(path), file)
  }
  const source = readFileSync(resolve(root, 'Logic.js'), 'utf8').replace(/^\.pragma library\s*$/m, '')
  new vm.Script(source, { filename: 'Logic.js' })
  const qmlformat = '/usr/lib/qt6/bin/qmlformat'
  if (!existsSync(qmlformat)) return // CI installs Qt; local pure-Node checks stay usable.
  for (const file of ['KeybindingsHint.qml', 'BindingViewport.qml']) {
    const parsed = spawnSync(qmlformat, [resolve(root, file)], { encoding: 'utf8', timeout: 10000 })
    assert.equal(parsed.status, 0, parsed.stderr)
  }
})
