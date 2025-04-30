# SincAlignNet
This implementation is based on the SincAlignNet model from the paper 'Frequency-Based Alignment of EEG and Audio Signals Using Contrastive Learning and SincNet for Auditory Attention Detection'. SincAlignNet is an innovative framework for auditory attention detection that aligns EEG and audio features by leveraging an enhanced version of SincNet along with contrastive learning. It achieves state-of-the-art accuracy on the KUL and DTU datasets and supports efficient low-density EEG decoding, making it suitable for practical neuro-guided hearing aids.

![image](https://github.com/user-attachments/assets/9195f49b-9458-496f-806a-38a7c2a9bbaf)

Fig. 1. The Framework of the SincAlignNet Model for AAD, which mainly consists of two parts: Contrastive Learning and Inference. Contrastive learning aligns EEG encoding with attended audio encoding by maximizing the mutual information of correct EEG-Audio pairs. Inference is used to identify the audio that the participant is attending to, by calculating the cosine similarity between EEG features and audio features, and also considering the use of EEG features for direct inference of the attended speaker.

 ![image](https://github.com/user-attachments/assets/97894fd8-581e-40b1-899a-8f9fa02fb92d)

Fig. 2. Details of the EEG encoder and Audio Encoder. Both the encoders consist of four main components: Multi-SincNet Bandpass, Depth Conv1D, Down Sample, and Projector. Initially, the input signal is processed by the SincNet Bandpass filter, which applies 60 filters for the EEG encoder and 320 filters for the audio encoder. Next, Depth Conv1D combines the outputs from these filters to extract deeper features. After that, the signal is compressed using a Down Sample module to reduce the data dimension while preserving key information. Finally, the Projector maps the data into a 128-dimensional feature space. 

![image](https://github.com/user-attachments/assets/b932075a-2395-4206-b065-e2a2e2527445)

Fig. 3. Details of each module. (a) Depth-wise 1D convolution block. (b) Down sample module. (c) Projector.


If any difficulties are encountered during reproducing our work, please contact the email address 1022020619@njupt.edu.cn as soon as possible, and we will respond promptly. Thank you for your time.

------------------------20241216--------------------------------

This project provides the implementation of the SincAlignNet, with code to reproduce all the results reported in the paper: (https://arxiv.org/abs/2503.04156)
