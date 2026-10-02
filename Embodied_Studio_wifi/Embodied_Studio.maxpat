{
  "patcher": {
    "fileversion": 1,
    "appversion": {
      "major": 9,
      "minor": 0,
      "revision": 0,
      "architecture": "x64",
      "modernui": 1
    },
    "rect": [
      40,
      40,
      1200,
      850
    ],
    "boxes": [
      {
        "box": {
          "id": "title",
          "maxclass": "comment",
          "patching_rect": [
            20,
            20,
            1100,
            22
          ],
          "fontsize": 20,
          "text": "EMBODIED STUDIO \u2014 open the Processing controller to perform"
        }
      },
      {
        "box": {
          "id": "info",
          "maxclass": "comment",
          "patching_rect": [
            20,
            60,
            1120,
            22
          ],
          "text": "Modes enable automatically with saved calibration. Space pauses. RAVE and track-volume audio stays in REAPER."
        }
      },
      {
        "box": {
          "id": "udp",
          "maxclass": "newobj",
          "patching_rect": [
            20,
            110,
            180,
            22
          ],
          "text": "udpreceive 12100"
        }
      },
      {
        "box": {
          "id": "route",
          "maxclass": "newobj",
          "patching_rect": [
            20,
            150,
            350,
            22
          ],
          "text": "route /suite/state /suite/load"
        }
      },
      {
        "box": {
          "id": "state",
          "maxclass": "newobj",
          "patching_rect": [
            20,
            190,
            180,
            22
          ],
          "text": "prepend state"
        }
      },
      {
        "box": {
          "id": "load",
          "maxclass": "newobj",
          "patching_rect": [
            240,
            190,
            180,
            22
          ],
          "text": "prepend load"
        }
      },
      {
        "box": {
          "id": "router",
          "maxclass": "newobj",
          "patching_rect": [
            20,
            230,
            400,
            22
          ],
          "text": "js studio_router.js"
        }
      },
      {
        "box": {
          "id": "basic",
          "maxclass": "newobj",
          "patching_rect": [
            20,
            320,
            270,
            22
          ],
          "text": "studio_basic"
        }
      },
      {
        "box": {
          "id": "formants",
          "maxclass": "newobj",
          "patching_rect": [
            305,
            320,
            270,
            22
          ],
          "text": "studio_formants"
        }
      },
      {
        "box": {
          "id": "formant_pitch",
          "maxclass": "newobj",
          "patching_rect": [
            590,
            320,
            270,
            22
          ],
          "text": "studio_formant_pitch"
        }
      },
      {
        "box": {
          "id": "coloratura",
          "maxclass": "newobj",
          "patching_rect": [
            875,
            320,
            270,
            22
          ],
          "text": "studio_coloratura"
        }
      },
      {
        "box": {
          "id": "granular",
          "maxclass": "newobj",
          "patching_rect": [
            20,
            430,
            270,
            22
          ],
          "text": "studio_granular"
        }
      },
      {
        "box": {
          "id": "stretch",
          "maxclass": "newobj",
          "patching_rect": [
            305,
            430,
            270,
            22
          ],
          "text": "studio_stretch"
        }
      },
      {
        "box": {
          "id": "rave",
          "maxclass": "newobj",
          "patching_rect": [
            590,
            430,
            270,
            22
          ],
          "text": "studio_rave"
        }
      },
      {
        "box": {
          "id": "send",
          "maxclass": "newobj",
          "patching_rect": [
            850,
            570,
            300,
            22
          ],
          "text": "udpsend 127.0.0.1 12101"
        }
      },
      {
        "box": {
          "id": "clip0",
          "maxclass": "newobj",
          "patching_rect": [
            20,
            570,
            180,
            22
          ],
          "text": "clip~ -0.95 0.95"
        }
      },
      {
        "box": {
          "id": "clip1",
          "maxclass": "newobj",
          "patching_rect": [
            260,
            570,
            180,
            22
          ],
          "text": "clip~ -0.95 0.95"
        }
      },
      {
        "box": {
          "id": "dac",
          "maxclass": "newobj",
          "patching_rect": [
            140,
            630,
            180,
            22
          ],
          "text": "dac~ 1 2"
        }
      },
      {
        "box": {
          "id": "help",
          "maxclass": "comment",
          "patching_rect": [
            20,
            710,
            1100,
            22
          ],
          "text": "All local audio runs here. REAPER receives the original /rave and /neutone controls on port 8000."
        }
      },
      {
        "box": {
          "id": "help2",
          "maxclass": "comment",
          "patching_rect": [
            20,
            745,
            1100,
            22
          ],
          "text": "Keep this patch, studio_*.maxpat, all JS files and grain_voice.maxpat in the same folder."
        }
      },
      {
        "box": {
          "id": "volume",
          "maxclass": "newobj",
          "text": "studio_volume",
          "patching_rect": [
            875,
            430,
            270,
            22
          ]
        }
      }
    ],
    "lines": [
      {
        "patchline": {
          "source": [
            "udp",
            0
          ],
          "destination": [
            "route",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "route",
            0
          ],
          "destination": [
            "state",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "route",
            1
          ],
          "destination": [
            "load",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "state",
            0
          ],
          "destination": [
            "router",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "load",
            0
          ],
          "destination": [
            "router",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "router",
            0
          ],
          "destination": [
            "basic",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "basic",
            2
          ],
          "destination": [
            "send",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "basic",
            0
          ],
          "destination": [
            "clip0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "basic",
            1
          ],
          "destination": [
            "clip1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "router",
            1
          ],
          "destination": [
            "formants",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "formants",
            2
          ],
          "destination": [
            "send",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "formants",
            0
          ],
          "destination": [
            "clip0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "formants",
            1
          ],
          "destination": [
            "clip1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "router",
            2
          ],
          "destination": [
            "formant_pitch",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "formant_pitch",
            2
          ],
          "destination": [
            "send",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "formant_pitch",
            0
          ],
          "destination": [
            "clip0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "formant_pitch",
            1
          ],
          "destination": [
            "clip1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "router",
            3
          ],
          "destination": [
            "coloratura",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "coloratura",
            2
          ],
          "destination": [
            "send",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "coloratura",
            0
          ],
          "destination": [
            "clip0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "coloratura",
            1
          ],
          "destination": [
            "clip1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "router",
            4
          ],
          "destination": [
            "granular",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "granular",
            2
          ],
          "destination": [
            "send",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "granular",
            0
          ],
          "destination": [
            "clip0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "granular",
            1
          ],
          "destination": [
            "clip1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "router",
            5
          ],
          "destination": [
            "stretch",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "stretch",
            2
          ],
          "destination": [
            "send",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "stretch",
            0
          ],
          "destination": [
            "clip0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "stretch",
            1
          ],
          "destination": [
            "clip1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "router",
            6
          ],
          "destination": [
            "rave",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "rave",
            0
          ],
          "destination": [
            "send",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "router",
            7
          ],
          "destination": [
            "send",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "clip0",
            0
          ],
          "destination": [
            "dac",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "clip1",
            0
          ],
          "destination": [
            "dac",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "router",
            8
          ],
          "destination": [
            "dac",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "router",
            9
          ],
          "destination": [
            "volume",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "volume",
            0
          ],
          "destination": [
            "send",
            0
          ]
        }
      }
    ]
  }
}