# tentacle_arm

**One capability bit from GBT V8, packaged standalone.** No. 283 of 341,
`system` domain (System).

<p>
<img alt="python" src="https://img.shields.io/badge/python-3.9%2B-blue">
<img alt="license" src="https://img.shields.io/badge/license-MIT-green">
<img alt="deps" src="https://img.shields.io/badge/runtime%20dependencies-0-brightgreen">
</p>

> **触手操控臂**（主人令 2026-10-19「你要以这些能力的思路来操控触手，本身触手就是我们的手，所以必须学会这样的操控精度」）：把 Omni-Arm 的五层精度模型套到能力位上 —— 关节 = 一次 (kind, op, payload)；`dof` = 该位在注册表登记的几个 op；`limits` **现算**（policy.evaluate 的作用域 ＋ preflight.is_side_effect 判出的处理器层闸），不手写；`reversible` 只读 op 才算可逆。op=status/limits/plan/where（纯读免门）· op=move 逐关节走 `run_task`，**票由那一位自己的门收**（本位不另加门、也不绕门），动完按 `expect` **量误差**（不把"调了"当"到了"）。冲击保护：缺票/缺必填参/读不出 op 一律**动手前**拒（fail-closed）

That description is copied verbatim from the registry. `tests/test_spec.py` pins it,
so documentation drift fails the build instead of shipping quietly.

## What this package actually is

It is the **contract** for one capability: its name, its parameters, the values it
accepts, and whether it can change state that cannot be restored. It is not the
implementation — that lives in the runtime this bit was extracted from.

So `run()` goes through a narrow `Backend` protocol, and the default backend is a
stub that **says so**:

```
status="validated"   backend="stub"   data={"executed": false}
```

Never `status="ok"`. A stub that reports success is worse than no stub, because the
caller stops looking for the real thing.

## Install

```bash
git clone https://github.com/gbtweilai-star/gbt-tentacle-arm.git
cd gbt-tentacle-arm
python -m pip install -e ".[dev]"
```

## Use

```bash
python -m gbt_tentacle_arm info                  # capability card
python -m gbt_tentacle_arm spec --json           # machine-readable contract
python -m gbt_tentacle_arm check --payload '{}'
python -m gbt_tentacle_arm run   --payload '{}'
```

Real `info` output from this machine:

```text
tentacle_arm  (system)  v1.0.0
----------------------------------------
**触手操控臂**（主人令 2026-10-19「你要以这些能力的思路来操控触手，本身触手就是我们的手，所以必须学会这样的操控精度」）：把 Omni-Arm 的五层精度模型套到能力位上 —— 关节 = 一次 (kind, op, payload)；`dof` = 该位在注册表登记的几个 op；`limits` **现算**（policy.evaluate 的作用域 ＋ preflight.is_side_effect 判出的处理器层闸），不手写；`reversible` 只读 op 才算可逆。op=status/limits/plan/where（纯读免门）· op=move 逐关节走 `run_task`，**票由那一位自己的门收**（本位不另加门、也不绕门），动完按 `expect` **量误差**（不把"调了"当"到了"）。冲击保护：缺票/缺必填参/读不出 op 一律**动手前**拒（fail-closed）

gated      : False
external   : False
multi-op   : True
params     : (none)
values     : status, limits, plan, where
```

Wire a real implementation:

```python
from gbt_tentacle_arm import run

class MyBackend:
    name = "my-backend"
    def invoke(self, cap, payload):
        return {"cap": cap, "handled": sorted(payload)}

result = run({}, backend=MyBackend())
assert result.status == "ok"
```

## Parameters

| name | required | notes |
|---|---|---|
| — | no | the registry declares no required parameters |

Registry hint (`params_hint`): (empty)

**注册表登记的取值 / 子动作（4 个）**：`status`、`limits`、`plan`、`where`

Types are deliberately absent: the registry does not declare them, and an invented
type is worse than no type, because callers believe it.

## Boundaries

- Not gated: the registry marks this bit `safe: true`.
- No external service dependency declared.
- Multi-op (`multi_op: true`): several sub-actions share one name — read `op` before calling.
- No implementation ships here. Bring a backend; the protocol is one method.

## What this is not

Not a wrapper around a hosted API. Not a model. Not a promise that calling it does
anything on its own. It is the typed seam plus the validation, which is the part that
stays correct even when the implementation changes.

## Tests

```bash
python -m pytest
```

```text
20 passed, 3 skipped in 0.10s
```

## Provenance

| field | value |
|---|---|
| capability | `tentacle_arm` |
| domain | `system` |
| handler | `tentacle_arm` |
| safe | `True` (gated = `False`) |
| external | `False` |
| atlas page | [system/tentacle_arm](https://github.com/gbtweilai-star/gbt-caps/blob/main/caps/system/tentacle_arm.md) |
| full index | [https://github.com/gbtweilai-star/gbt-caps](https://github.com/gbtweilai-star/gbt-caps) |

The parent README says 348 capabilities; an AST pass over the registry enumerates
`341 + 0 unimplemented + 0 disabled = 341`. The extra 7 are historical duplicates.
Numbering here follows 341 and matches the `gbt-caps` index one-to-one.

## License

MIT.
