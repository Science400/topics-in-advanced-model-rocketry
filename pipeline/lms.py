"""
LM Studio management API helpers.

Handles loading and unloading models via the LM Studio REST API so scripts
don't need to ask the user to do it manually.
"""

import httpx

from config import LM_STUDIO_BASE_URL, LOAD_CONFIGS
from term import console

# Management API lives on the same host but at /api/v1 (not /v1)
_BASE = LM_STUDIO_BASE_URL.replace("/v1", "")


class LMStudioError(RuntimeError):
    """A management-API call failed, carrying LM Studio's own explanation."""


def _mgmt(method: str, path: str, **kwargs):
    url = f"{_BASE}/api/v1{path}"
    r = httpx.request(method, url, timeout=300, **kwargs)
    if r.is_error:
        # raise_for_status() reports only "500 Internal Server Error", while the
        # body says what actually went wrong — a missing model, or an engine
        # that aborted on load. Losing that turns a one-line diagnosis into a
        # session of curling the endpoint by hand.
        detail = ""
        try:
            body = r.json()
            detail = body.get("error", {}).get("message") or str(body)
        except Exception:
            detail = r.text[:400]
        raise LMStudioError(f"{r.status_code} from {path}: {detail}")
    return r.json()


def loaded_llms() -> list[dict]:
    """Return list of {key, instance_id} for currently loaded LLMs."""
    data = _mgmt("GET", "/models")
    result = []
    for m in data["models"]:
        if m["type"] != "llm":
            continue
        for inst in m.get("loaded_instances", []):
            result.append({"key": m["key"], "instance_id": inst["id"]})
    return result


def unload_all():
    """Unload every currently loaded LLM."""
    for m in loaded_llms():
        console.print(f"  [dim]unloading {m['instance_id']}...[/]")
        _mgmt("POST", "/models/unload", json={"instance_id": m["instance_id"]})


def ensure_models_loaded(model_keys: list[str]):
    """
    Bring loaded LLMs into sync with model_keys.
    Unloads any model not in model_keys; loads any model not yet running.
    """
    current = loaded_llms()
    current_ids = {m["instance_id"] for m in current}

    for m in current:
        if m["instance_id"] not in model_keys:
            console.print(f"  [dim]unloading {m['instance_id']}...[/]")
            _mgmt("POST", "/models/unload", json={"instance_id": m["instance_id"]})

    for key in model_keys:
        if key not in current_ids:
            payload: dict = {"model": key, "echo_load_config": True}
            payload.update(LOAD_CONFIGS.get(key, {}))
            with console.status(f"[cyan]loading {key}...[/]"):
                result = _mgmt("POST", "/models/load", json=payload)
            elapsed = result.get("load_time_seconds", 0)
            console.print(f"  [green]✓[/] {key} loaded in {elapsed:.1f}s")
        else:
            console.print(f"  [dim]{key} already loaded[/]")


def ensure_loaded(model_key: str):
    """
    Make sure model_key is the only loaded LLM.
    If it is already loaded, do nothing.
    If a different model is loaded, unload it first, then load model_key.
    """
    current = loaded_llms()
    ids = [m["instance_id"] for m in current]

    if model_key in ids:
        console.print(f"  [dim]{model_key} already loaded[/]")
        return

    # Unload whatever else is running
    for m in current:
        console.print(f"  [dim]unloading {m['instance_id']}...[/]")
        _mgmt("POST", "/models/unload", json={"instance_id": m["instance_id"]})

    # Build load payload
    payload: dict = {"model": model_key, "echo_load_config": True}
    cfg = LOAD_CONFIGS.get(model_key, {})
    payload.update(cfg)

    with console.status(f"[cyan]loading {model_key}...[/]"):
        result = _mgmt("POST", "/models/load", json=payload)
    elapsed = result.get("load_time_seconds", 0)
    console.print(f"  [green]✓[/] {model_key} loaded in {elapsed:.1f}s")
