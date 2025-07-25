#!/usr/bin/env python3
# PATCH-P0004: hardening agent_health script
import os
import json
import subprocess
import shlex
from datetime import datetime

LLMSTATE_DIR = '.llmstate'
HEALTH_LOG = os.path.join(LLMSTATE_DIR, 'agent-health.jsonl')
AGENTS_MD = 'AGENTS.md'


def load_agents_from_md():
    agents = {}
    if not os.path.exists(AGENTS_MD):
        return agents
    with open(AGENTS_MD, 'r') as f:
        lines = f.readlines()
    in_registry = False
    for line in lines:
        if line.strip().lower().startswith('## agent registry'):
            in_registry = True
            continue
        if in_registry:
            if line.startswith('#'):
                # new section
                break
            if '|' in line:
                parts = [p.strip() for p in line.strip().strip('|').split('|')]
                if len(parts) >= 2 and parts[0] and not set(parts[0]) <= {'-', ' '} and parts[0].lower() != 'agent':
                    agents[parts[0]] = parts[1]
    return agents


def load_agents_from_state():
    agents = set()
    if not os.path.isdir(LLMSTATE_DIR):
        return agents
    for fname in os.listdir(LLMSTATE_DIR):
        if fname.endswith('.jsonl'):
            try:
                with open(os.path.join(LLMSTATE_DIR, fname), 'r') as f:
                    for line in f:
                        try:
                            j = json.loads(line)
                        except json.JSONDecodeError:
                            continue
                        for key in ('agent', 'name'):
                            if key in j:
                                agents.add(j[key])
            except FileNotFoundError:
                continue
    return agents


def now_ts():
    return datetime.utcnow().isoformat() + 'Z'


def append_log(record):
    os.makedirs(LLMSTATE_DIR, exist_ok=True)
    with open(HEALTH_LOG, 'a') as f:
        f.write(json.dumps(record, ensure_ascii=False) + '\n')


def run_health_check(tag, agent, cmd):
    start = now_ts()
    try:
        # More comprehensive security check
        dangerous_chars = (';', '|', '&', '$', '<', '>', '`', '(', ')', '{', '}', '[', ']', '\\', '"', "'", '~', '*', '?', '!')
        if any(c in cmd for c in dangerous_chars):
            raise ValueError(f'Unsafe characters in command: {cmd}')
        
        # Use shlex for proper command parsing
        parts = shlex.split(cmd)
        if not parts:
            raise ValueError('Empty command')
            
        result = subprocess.run(parts, stdout=subprocess.PIPE,
                                stderr=subprocess.STDOUT, timeout=30)
        status = 'ok' if result.returncode == 0 else 'fail'
        output = result.stdout.decode(errors='replace').strip()
    except Exception as e:
        status = 'error'
        output = str(e)
    record = {
        'tag': tag,
        'timestamp': start,
        'agent': agent,
        'status': status,
        'output': output,
    }
    append_log(record)
    return record


def main():
    tag = os.environ.get('TAG', 'HEALTH-1')
    all_agents = load_agents_from_md()
    state_agents = load_agents_from_state()
    for a in state_agents:
        if a not in all_agents:
            all_agents[a] = ''

    if not all_agents:
        append_log({'tag': tag, 'timestamp': now_ts(),
                    'agent': None, 'event': 'no-agents-found'})
        return

    for agent, cmd in all_agents.items():
        if cmd:
            run_health_check(tag, agent, cmd)
        else:
            append_log({'tag': tag, 'timestamp': now_ts(),
                        'agent': agent, 'status': 'unknown', 'output': ''})

    append_log({'tag': tag, 'timestamp': now_ts(),
                'agent': None, 'event': 'completed'})

if __name__ == '__main__':
    main()
