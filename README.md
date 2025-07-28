# SincAlignNet

**Implementation based on:**  
*Frequency-Based Alignment of EEG and Audio Signals Using Contrastive Learning and SincNet for Auditory Attention Detection*  

SincAlignNet is an innovative framework for auditory attention detection that aligns EEG and audio features using an enhanced SincNet architecture with contrastive learning. It achieves state-of-the-art accuracy on KUL and DTU datasets, supporting efficient low-density EEG decoding for practical neuro-guided hearing aids.

---

## Framework Overview
![SincAlignNet Framework](https://github.com/user-attachments/assets/0cd0c99a-a2b9-432c-bf9e-f89404e5923c)  
**Fig. 1:** SincAlignNet architecture for AAD, consisting of two phases:  
1. **Contrastive Learning** - Aligns EEG and attended audio encodings by maximizing mutual information of correct EEG-Audio pairs  
2. **Inference** - Identifies attended audio via cosine similarity between EEG/audio features or direct EEG-based inference

---

## Encoder Architecture
![EEG/Audio Encoders](https://github.com/user-attachments/assets/3145356c-75be-4f29-9461-3050ee99677a)  
**Fig. 2:** EEG and Audio encoder structure. Both encoders contain four components:  
1. **Multi-SincNet Bandpass**  
   - EEG: 60 filters | Audio: 320 filters  
2. **Depth Conv1D** - Combines filter outputs for deeper features  
3. **Down Sample** - Compresses data while preserving key information  
4. **Projector** - Maps features to 128D latent space  

---

## Module Specifications
<img width="525" height="414" alt="image" src="https://github.com/user-attachments/assets/b74521b9-c58e-41f2-8865-4205f79812d5" />

**Fig. 3:** Component implementations:  
(a) Depth-wise 1D convolution block  
(b) Down sample module  
(c) Projector architecture  

---

## Biological Motivation
![Model Assumptions](https://github.com/user-attachments/assets/1685dee1-f077-4200-a9c4-dc88f8ca806e)  
**Fig. 4:** Proposed auditory attention mechanisms:  
1. **Noise Reduction (Fig 4a)**  
   - Brain processes mixed audio → extracts attended speaker  
   - Simulated using SincNet filtering architecture  

2. **Information Minimization (Fig 4b)**  
   - Attentional focus minimizes mutual information entropy  
   - Implemented via contrastive learning paradigm  

---
