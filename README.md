# OSINT Political Narrative Analysis Framework

## Overview

This repository provides a reusable analytical framework for studying political narratives, public opinion, and behavioral patterns in social media data.

The framework is designed for projects that combine OSINT, social media analysis, NLP, and political behavior research. It focuses on how public discourse forms around crises, how key actors are perceived, and how narratives evolve across time, users, and platforms.

This repository is a methodological framework. Applied country-level case studies are maintained as separate repositories.

---

## Core Purpose

The framework is built to answer questions such as:

- How are political narratives structured in social media discourse?
- Which actors become central in public perception during crises?
- How do users frame threat, security, identity, diplomacy, and regional conflict?
- How do institutional, media, influencer, and ordinary-user accounts differ in framing events?
- How does online public opinion shift over time?
- Which themes carry high sensitivity or de-escalation potential?

---

## Analytical Layers

### 1. Data Audit Layer

- Dataset structure review
- File comparison and validation
- Missing-value analysis
- Duplicate detection
- Distinction between raw rows, unique posts, and unique users

### 2. Metadata and Engagement Layer

- Impressions
- Views
- Likes
- Replies
- Reposts
- Quotes
- Account-level activity

This layer helps distinguish between content volume and actual visibility or influence.

### 3. Topic Layer

Topic classification is designed to be mutually exclusive. Each post is assigned to one dominant topic, and topic shares should sum to 100 percent.

### 4. Narrative Layer

Narrative mapping is based on co-occurrence and semantic connections between themes.

This layer identifies:

- Central narrative nodes
- Co-occurring themes
- Narrative clusters

### 5. Stance Layer

Stance analysis identifies positive and negative attitudes toward key actors, policies, and crisis-related issues.

### 6. Account-Type Layer

Accounts can be grouped into:

- Official and institutional accounts
- Media and news accounts
- Influencers and analysts
- Ordinary users

### 7. Temporal Layer

- Daily content volume
- Daily impressions
- Discourse waves
- Narrative shifts over time

### 8. Strategic Interpretation Layer

- Sensitivity matrix
- De-escalation potential
- Narrative risk mapping
- Strategic implications
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
  engagement_metrics.py

notebooks/
  01_data_audit.ipynb
  02_metadata_and_deduplication.ipynb
  03_temporal_analysis.ipynb
  04_topic_classification.ipynb
  05_narrative_mapping.ipynb
  06_stance_analysis.ipynb
  07_account_type_analysis.ipynb
  08_report_tables.ipynb

outputs/
  tables/
  figures/

reports/
  final_report_summary.md

dashboard/
  app.py
خo
```


## Methodological Principles

- Raw datasets are not publicly shared when privacy, platform, or organizational restrictions apply.
- Reports should clearly distinguish between raw rows, unique posts, and unique users.
- Topic classification should be mutually exclusive when percentage shares are reported.
- Narrative mapping can be non-exclusive because it represents semantic relationships.
- Engagement-weighted analysis should be separated from content-volume analysis.
- Account-type comparisons should clarify whether influence is driven by institutions, media, influencers, or ordinary users.
- Strategic recommendations should be derived from the data and limited to public communication, transparency, de-escalation, and risk reduction.
---

## Applied Case Studies

This framework is intended to support separate country-level or case-level repositories.

Current and planned applications include:

- Kuwait public opinion on the Iran 2026 War
- Qatar public opinion on the Iran 2026 War
- United Arab Emirates public opinion on the Iran 2026 War

Each case study should have its own repository, dataset notes, methodology, report summary, and publication-safe outputs.

---

## Data Availability

The original datasets used in applied projects may not be publicly shared due to privacy, platform, and organizational restrictions.

When raw data cannot be shared, repositories should still include:

- Project structure
- Methodology
- Data dictionary, when safe
- Reproducible code templates
- Aggregated tables
- Visual outputs
- Report summaries
- Ethical and methodological notes

---

## Outputs

This framework supports the production of:

- Data audit summaries
- Deduplication reports
- Topic distribution tables
- Narrative co-occurrence maps
- Stance analysis tables
- Account-type comparison tables
- Daily trend tables
- Sensitivity matrices
- Strategic analytical reports
- Dashboard prototypes

---

## Tools and Technologies

- Python
- pandas
- NumPy
- scikit-learn
- NLP libraries such as NLTK or spaCy
- Matplotlib
- Seaborn
- Plotly
- Streamlit
- Google AppSheet, when relevant for internal policy-analysis interfaces
---

## Status

Core framework established.

Next steps:

- Add reusable notebook templates
- Add sample synthetic data
- Build the Kuwait case-study repository
- Add example output tables and figures
- Develop a simple dashboard prototype
---
## Disclaimer

This repository represents independent methodological and portfolio work. It does not represent any organization, employer, client, or institution.

Raw datasets and sensitive operational details are not included.

---

## Author

Mohammad Mahdi Saeedimehr  

Political and Behavioral Data Analyst  
Computational Social Science | OSINT | Public Opinion Analysis  

Focus: Middle East, political narratives, social media data analysis, and crisis-related public perception
