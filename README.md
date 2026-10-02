# Embodied Synthesiser Workshop

Participant preparation guide · Diana Alina Serbanescu / Neranti

**When:** [6/10/2026 / 16:00]  
**Where:** Sala Aranyó, UPF Campus Poblenou, Carrer de Roc Boronat 138, Barcelona.   
**Contact:** diana@replica.institute // diana.serbanescu@zhdk.ch

## What we will explore

How can a textile become a musical interface? What changes when we shape sound through tension, release and movement?

<img width="1500" height="999" alt="_KAT5744_web_cover" src="https://github.com/user-attachments/assets/58458f99-cfea-45bf-a48b-50c1854eb465" />

This introductory workshop connects a wearable stretch sensor to sound synthesis. We will explore how a physical gesture can shape a tone, a vocal quality or a sound texture, then use bodily interaction to manipulate pretrained RAVE neural audio models.

The emphasis is on the relationship between movement and listening: hearing what a gesture does, adjusting it, and discovering how the sound influences the next movement. We will introduce the machine-learning concepts needed to explore these models. Training a new neural audio model from scratch is outside the practical scope of the workshop.

RAVE learns a compressed representation of audio, often called a *latent space*. Changing its latent controls changes the resulting sound. Our sensor mappings give us a physical way to explore those controls; the mappings themselves need not be learned by AI. See the [RAVE paper](https://arxiv.org/abs/2111.05011) for the research background.

## What to bring

- A laptop (MacBook if available), charger and permission to install applications and audio plugins.
- An iPhone and a cable to connect it to your laptop. The phone will help us set up a local Wi-Fi hotspot on the laptop so the ESP32-S3 can connect wirelessly. We will configure this together during the workshop.
- Comfortable clothing for gentle movement.

Each participant will receive an ESP32-S3 microcontroller, a stretch sensor and a connector at the beginning of the workshop. Connection and calibration will be guided during the session.

<img width="571" height="428" alt="toolkit" src="https://github.com/user-attachments/assets/a1f3f03b-4fcd-4a28-8d99-4d1ee48eb6ed" />

The examples have been tested on **macOS**. This does not establish compatibility with every Mac or other operating systems. Let us know about access needs that may affect movement or use of the sensor.

## Software for the workshop

We’ll download, install and check the software together during the workshop. Installers should match your operating system and processor.

| Software | Role in the workshop | Preparation |
|---|---|---|
| [Processing 4](https://processing.org/download/) | Reads sensor data and runs the control interface | Install Processing and add **Sound** and **oscP5** through the library manager. |
| [Max](https://cycling74.com/downloads/) | Runs the synthesis patches and passes controls between applications | Install the standalone Max application and open it once. |
| [REAPER](https://www.reaper.fm/download.php) | Hosts the audio plugins and sound sources for neural-audio examples | Install and open it once. |
| [RAVE VST](https://forum.ircam.fr/projects/detail/rave-vst/) | Runs compatible pretrained RAVE models in a DAW | Install the plugin for the prepared RAVE example. |
| [Neutone FX](https://neutone.jp/fx) | Hosts compatible neural-audio models for the Neutone example | Install the FX plugin and check that REAPER can find it. |

**Intel Mac note:** Neutone's download page says Intel support was discontinued from version 1.6.1; Intel users need version 1.6.0 or earlier. Confirm the workshop-compatible version with the facilitator. [Neutone FX downloads](https://neutone.jp/fx).

Max currently offers a 30-day trial and REAPER a 60-day evaluation. If you plan to use these, check that your evaluation period covers the workshop. [Max downloads](https://cycling74.com/downloads/), [REAPER downloads](https://www.reaper.fm/download.php).

### Processing libraries

In Processing, open the library manager via **Sketch → Import Library → Manage Libraries…**, search for **Sound** and **oscP5**, and install them. Some examples generate audio in Processing and need Sound; others send controls to Max and need oscP5. USB examples also use Processing's supplied Serial library.

You do not need to install Python, a RAVE training environment, Wekinator or ml.lib for the preparation described here. 


## Download the workshop pack

Download the **[Embodied Synthesiser Software Pack (ZIP)](https://github.com/DianaAlinaSerbanescu/embodied-synthesisers-workshop-barcelona/archive/refs/heads/main.zip)**, or visit the [GitHub repository](https://github.com/DianaAlinaSerbanescu/embodied-synthesisers-workshop-barcelona) and choose **Code → Download ZIP**.

Unzip the complete folder onto your laptop. Keep the accompanying `.pde`, `.java`, `.maxpat`, `.js` and audio files in their original folders; the examples depend on these relationships.

The pack includes the Embodied Studio interfaces, individual Processing + Max examples, and Arduino firmware for the sensor board.

**We’ll explore and check everything in the software pack step by step together during the workshop.** I’ll guide you through which files to open, the connections and settings to use, and how to explore the sounds. There is no need to work through the examples independently beforehand.

## Setup checks we’ll do together

- Processing opens, and Sound and oscP5 appear in its installed libraries.
- Max and REAPER open successfully.
- REAPER can find the installed RAVE and Neutone FX plugins.
- The workshop pack is downloaded and extracted locally.


## During the workshop

We will connect the sensor, check that readings respond to stretch, and calibrate a relaxed position and a comfortable stretched position. Calibration adapts the interface to the material and the gesture you want to use.

The example collection includes tones and notes, filtered noise, vowel-like synthesis, sample-based textures and neural-audio control. We will use selected examples to explore the relationship between physical action and sound.

Try changing one quality at a time: a slow stretch, a held position, a small repeated movement, or a gradual release. Listen for what changes and what remains stable. With neural audio, the sonic effect depends on the model and mapping; a control does not necessarily correspond to a familiar musical property such as pitch.

Use the instructions for the selected example. Controls and release behaviour differ across versions: releasing a sensor may silence audio, pause playback or return a parameter. The facilitator will demonstrate the behaviour of the workshop version.

## Credits

Please credit the custom workshop model as:

> Custom RAVE model: REPLICA and Diana Alina Serbanescu (Neranti).

Retain the credits and licence information supplied with the software, models and source material. See the model's accompanying documentation for its terms of use.

## Optional reading and further exploration

These resources are for continuing after the workshop; they are not preparation requirements.

- [RAVE overview and tools](https://forum.ircam.fr/collections/detail/rave/)
- [RAVE research paper — Antoine Caillon and Philippe Esling](https://arxiv.org/abs/2111.05011)
- [Public RAVE models](https://acids-ircam.github.io/rave_models_download)
- [Training RAVE on custom data](https://forum.ircam.fr/article/detail/training-rave-models-on-custom-data/)
- [Jasper's RAVE models](https://huggingface.co/shuoyang-zheng/jaspers-rave-models)
- [Jasper's latent terrain synthesis — building terrains](https://jasper-zheng.github.io/nn_terrain/instructions/build-terrain/)
- [Latent terrain synthesis video](https://www.youtube.com/watch?v=pAWJsSA4ZKQ)
- [ml.lib for Max](https://cycling74.com/packages/mllib)
- [Wekinator](https://doc.gold.ac.uk/~mas01rf/Wekinator/)
