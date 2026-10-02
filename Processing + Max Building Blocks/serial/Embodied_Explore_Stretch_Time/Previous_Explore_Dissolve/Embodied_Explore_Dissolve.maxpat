{
  "patcher": {
    "fileversion": 1,
    "appversion": {
      "major": 8,
      "minor": 6,
      "revision": 0,
      "architecture": "x64",
      "modernui": 1
    },
    "rect": [
      80,
      80,
      1100,
      760
    ],
    "default_fontsize": 12.0,
    "default_fontname": "Arial",
    "boxes": [
      {
        "box": {
          "id": "title",
          "maxclass": "comment",
          "patching_rect": [
            25,
            20,
            1000,
            22
          ],
          "fontsize": 20.0,
          "text": "EXPLORE AND DISSOLVE \u2014 MAX GRANULAR ENGINE"
        }
      },
      {
        "box": {
          "id": "info",
          "maxclass": "comment",
          "patching_rect": [
            25,
            55,
            1030,
            22
          ],
          "text": "Processing: L load WAV/AIFF | A0 scan + gate | A1 fragments 250\u201320 ms | D enable | M/Q mute."
        }
      },
      {
        "box": {
          "id": "udp",
          "maxclass": "newobj",
          "patching_rect": [
            25,
            105,
            180,
            22
          ],
          "text": "udpreceive 12000"
        }
      },
      {
        "box": {
          "id": "route",
          "maxclass": "newobj",
          "patching_rect": [
            25,
            145,
            320,
            22
          ],
          "text": "route /granular/state /granular/load"
        }
      },
      {
        "box": {
          "id": "state",
          "maxclass": "newobj",
          "patching_rect": [
            25,
            190,
            150,
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
            235,
            190,
            150,
            22
          ],
          "text": "prepend load"
        }
      },
      {
        "box": {
          "id": "js",
          "maxclass": "newobj",
          "patching_rect": [
            25,
            245,
            850,
            22
          ],
          "text": "js granular_engine.js #0-explore"
        }
      },
      {
        "box": {
          "id": "buf",
          "maxclass": "newobj",
          "patching_rect": [
            650,
            105,
            220,
            22
          ],
          "text": "buffer~ #0-explore 0 2"
        }
      },
      {
        "box": {
          "id": "loaded",
          "maxclass": "message",
          "patching_rect": [
            650,
            150,
            70,
            22
          ],
          "text": "loaded"
        }
      },
      {
        "box": {
          "id": "lb",
          "maxclass": "newobj",
          "patching_rect": [
            430,
            105,
            80,
            22
          ],
          "text": "loadbang"
        }
      },
      {
        "box": {
          "id": "one",
          "maxclass": "message",
          "patching_rect": [
            430,
            145,
            40,
            22
          ],
          "text": "1"
        }
      },
      {
        "box": {
          "id": "metro",
          "maxclass": "newobj",
          "patching_rect": [
            430,
            185,
            80,
            22
          ],
          "text": "metro 5"
        }
      },
      {
        "box": {
          "id": "tick",
          "maxclass": "message",
          "patching_rect": [
            530,
            185,
            50,
            22
          ],
          "text": "tick"
        }
      },
      {
        "box": {
          "id": "poly",
          "maxclass": "newobj",
          "patching_rect": [
            25,
            320,
            340,
            22
          ],
          "text": "poly~ grain_voice 64 @args #0-explore"
        }
      },
      {
        "box": {
          "id": "master",
          "maxclass": "newobj",
          "patching_rect": [
            410,
            320,
            100,
            22
          ],
          "text": "line~ 0."
        }
      },
      {
        "box": {
          "id": "send",
          "maxclass": "newobj",
          "patching_rect": [
            700,
            320,
            240,
            22
          ],
          "text": "udpsend 127.0.0.1 12001"
        }
      },
      {
        "box": {
          "id": "monogain",
          "maxclass": "newobj",
          "patching_rect": [
            200,
            375,
            70,
            22
          ],
          "text": "*~ 0."
        }
      },
      {
        "box": {
          "id": "right",
          "maxclass": "newobj",
          "patching_rect": [
            200,
            420,
            50,
            22
          ],
          "text": "+~"
        }
      },
      {
        "box": {
          "id": "amp0",
          "maxclass": "newobj",
          "patching_rect": [
            25,
            470,
            60,
            22
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "clip0",
          "maxclass": "newobj",
          "patching_rect": [
            25,
            515,
            150,
            22
          ],
          "text": "clip~ -0.95 0.95"
        }
      },
      {
        "box": {
          "id": "amp1",
          "maxclass": "newobj",
          "patching_rect": [
            225,
            470,
            60,
            22
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "clip1",
          "maxclass": "newobj",
          "patching_rect": [
            225,
            515,
            150,
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
            125,
            565,
            100,
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
            25,
            625,
            1030,
            22
          ],
          "text": "64 windowed grain voices. Mono is duplicated to both outputs; stereo preserves its channels. OSC timeout: 500 ms."
        }
      },
      {
        "box": {
          "id": "help2",
          "maxclass": "comment",
          "patching_rect": [
            25,
            655,
            1030,
            22
          ],
          "text": "Keep granular_engine.js and grain_voice.maxpat beside this patch. All performance controls stay in Processing."
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
            "js",
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
            "js",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "buf",
            1
          ],
          "destination": [
            "loaded",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "loaded",
            0
          ],
          "destination": [
            "js",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "js",
            4
          ],
          "destination": [
            "buf",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "lb",
            0
          ],
          "destination": [
            "one",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "one",
            0
          ],
          "destination": [
            "metro",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "metro",
            0
          ],
          "destination": [
            "tick",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "tick",
            0
          ],
          "destination": [
            "js",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "js",
            0
          ],
          "destination": [
            "poly",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "js",
            1
          ],
          "destination": [
            "master",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "js",
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
            "poly",
            0
          ],
          "destination": [
            "monogain",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "js",
            5
          ],
          "destination": [
            "monogain",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "monogain",
            0
          ],
          "destination": [
            "right",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "poly",
            1
          ],
          "destination": [
            "right",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "poly",
            0
          ],
          "destination": [
            "amp0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "master",
            0
          ],
          "destination": [
            "amp0",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "amp0",
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
            "right",
            0
          ],
          "destination": [
            "amp1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "master",
            0
          ],
          "destination": [
            "amp1",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "amp1",
            0
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
            "js",
            3
          ],
          "destination": [
            "dac",
            0
          ]
        }
      }
    ]
  }
}