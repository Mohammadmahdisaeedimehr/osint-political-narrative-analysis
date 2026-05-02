# OSINT Political Narrative Analysis Framework

## Overview

This repository provides a reusable analytical framework for studying political narratives, public opinion, and behavioral patterns in social media environments using natural language processing (NLP), OSINT methodologies, and data-driven analysis.

The framework is designed to move beyond simple sentiment analysis and instead capture how narratives are constructed, how threats are perceived, and how public discourse evolves in response to geopolitical events.

---

## Core Purpose

The project focuses on answering a deeper layer of analytical questions:

- How are political narratives formed and structured in social media?
- What drives negative or positive perception toward key actors?
- How do security, economic, and identity concerns combine in public opinion?
- How do institutional actors differ from ordinary users in framing reality?
- How do crises become localized in public perception?

---

## Analytical Layers

The framework operates across multiple analytical layers:

### 1. Narrative Layer
- Identification of dominant narratives
- Narrative clustering and thematic segmentation
- Co-occurrence and narrative network mapping

### 2. Topic Layer
- Mutually exclusive topic classification
- Share-based distribution analysis
- Structural mapping of discourse

### 3. Stance Layer
- Binary stance classification (positive vs negative)
- Actor-specific perception analysis
- Crisis-related positioning

### 4. Behavioral Layer
- Emotion-driven reactions (fear, anger, threat perception)
- Risk perception and security sensitivity
- Collective behavioral patterns

### 5. Temporal Layer
- Time-series analysis of discourse
- Crisis evolution tracking
- Narrative shifts over time

---

## Project Architecture

```text
data/
  raw/
  processed/
  sample/

src/
  data_cleaning.py
  deduplication.py
  text_preprocessing.py
  topic_classification.py
  narrative_mapping.py
  stance_detection.py
  emotion_analysis.py

notebooks/
dashboard/
report/
docs/
```




## Methodological Principles

- Topic classification is strictly mutually exclusive and sums to 100%
- Narrative mapping is based on co-occurrence and is not forced to sum
- All analysis is data-driven and reproducible
- Raw datasets are not publicly shared for privacy and ethical reasons
- Outputs are designed for direct use in research, policy, and strategic analysis

---

## Applied Project: GCC Public Opinion Analysis

This framework is currently applied in a multi-country analytical project:

### Public Opinion in the Persian Gulf toward the Iran 2026 War

Countries covered:

- Bahrain
- Qatar (planned)
- Kuwait (planned)
- United Arab Emirates (planned)

This applied project transforms the framework into real-world analytical reports including:

- Narrative maps
- Stance distributions
- Sensitivity matrices
- Public opinion dynamics
- Policy-relevant insights

---

## Outputs

- Cleaned and structured datasets
- Narrative and topic distributions
- Stance analysis toward key actors
- Account-type comparative analysis
- Sensitivity and risk matrices
- Strategic analytical reports
- Visualization dashboards

---

## Tools and Technologies

- Python
- pandas, numpy
- scikit-learn
- NLP libraries (NLTK, spaCy)
- matplotlib, seaborn, plotly
- Streamlit

---

## Current Status

Core framework is established.

First applied case:
- Bahrain public opinion toward the Iran 2026 War (completed)

Next steps:
- Extend to Qatar, Kuwait, and UAE
- Build comparative Gulf-level analysis
- Develop interactive dashboards

---

## Author

Political and Behavioral Data Analyst

Focused on:
- Public opinion analysis
- OSINT and social media intelligence
- Political narrative analysis
- NLP and computational social science

Background in:
- Political sociology
- Cognitive science
- Behavioral analysis

