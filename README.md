# SincAlignNet
This implementation is based on the SincAlignNet model from the paper 'Frequency-Based Alignment of EEG and Audio Signals Using Contrastive Learning and SincNet for Auditory Attention Detection'. SincAlignNet is an innovative framework for auditory attention detection that aligns EEG and audio features by leveraging an enhanced version of SincNet along with contrastive learning. It achieves state-of-the-art accuracy on the KUL and DTU datasets and supports efficient low-density EEG decoding, making it suitable for practical neuro-guided hearing aids.

<img width="691" height="666" alt="image" src="https://github.com/user-attachments/assets/0cd0c99a-a2b9-432c-bf9e-f89404e5923c" />

Fig. 1. The Framework of the SincAlignNet Model for AAD, which mainly consists of two parts: Contrastive Learning and Inference. Contrastive learning aligns EEG encoding with attended audio encoding by maximizing the mutual information of correct EEG-Audio pairs. Inference is used to identify the audio that the participant is attending to, by calculating the cosine similarity between EEG features and audio features, and also considering the use of EEG features for direct inference of the attended speaker.

<img width="766" height="482" alt="image" src="https://github.com/user-attachments/assets/3145356c-75be-4f29-9461-3050ee99677a" />

Fig. 2. Details of the EEG encoder and Audio Encoder. Both the encoders consist of four main components: Multi-SincNet Bandpass, Depth Conv1D, Down Sample, and Projector. Initially, the input signal is processed by the SincNet Bandpass filter, which applies 60 filters for the EEG encoder and 320 filters for the audio encoder. Next, Depth Conv1D combines the outputs from these filters to extract deeper features. After that, the signal is compressed using a Down Sample module to reduce the data dimension while preserving key information. Finally, the Projector maps the data into a 128-dimensional feature space. 

<img width="525" height="414" alt="image" src="https://github.com/user-attachments/assets/517b6782-35c8-4c1f-a256-8f36855cabd2" />

Fig. 3. Details of each module. (a) Depth-wise 1D convolution block. (b) Down sample module. (c) Projector.

 <img width="525" height="235" alt="image" src="https://github.com/user-attachments/assets/1685dee1-f077-4200-a9c4-dc88f8ca806e" />
To emulate the human brain's flexible auditory attention selection capabilities, we propose a frequency-aligned contrastive learning paradigm based on the following assumptions:
1) As illustrated in Fig. 4 (a), the brain receives mixed audio signals and is capable of performing noise reduction to ultimately obtain relatively clear audio of the attended speaker. We hypothesize that this noise reduction process can be modeled using the SincNet architecture to simulate the filtering process.
2) In noisy environments, when humans focus their attention on a single speaker, we assume that, from an information entropy perspective, the brain's processing of the heard audio minimizes mutual information entropy as much as possible. We simulate this process using the contrastive learning approach depicted in Fig. 4 (b).
Building on the two assumptions, we will further elaborate on the proposed SincAlignNet model in this paper.

Fig. 4. Illustration of Model Assumptions. (a) Noise Reduction Process using SincNet; (b) Contrastive Learning Approach for Minimizing Mutual Information Entropy.
