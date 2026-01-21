# Why do we use `-it` with `docker run`

## Overview
Many container commands exit immediately or behave strangely without `-it`.  
This document explains **why `-i` and `-t` exist**, not just how to use them.

---

## Diagram

![Why docker run -it](../diagrams/png/why-docker-run-it.png)

- **Interactive Excalidraw (editable):**  
  https://excalidraw.com/#json=Kzh9VB1zobtLjw7v5YJ1v,cHarYB_E71oVh58Vco79Ww

---

## What `-i` Does
- Keeps **STDIN open**
- Required for programs like `cat`, `python`, `bash`

## What `-t` Does
- Allocates a **pseudo-TTY**
- Enables:
  - Line buffering
  - Ctrl+C / signals
  - Prompt rendering

---

## Behavior Comparison

```bash
docker run ubuntu cat
docker run -i ubuntu cat
docker run -t ubuntu bash
docker run -it ubuntu bash
