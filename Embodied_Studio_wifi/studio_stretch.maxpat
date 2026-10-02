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
          "text": "STRETCH TIME \u2014 INDEPENDENT SPEED AND PITCH"
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
          "text": "Processing: L load | A0 speed + gate | A1 pitch | D enable | M/Q mute | T restart"
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
          "text": "js stretch_time_engine.js #0-stretch"
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
          "text": "buffer~ #0-stretch 0 2"
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
          "text": "metro 20"
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
          "id": "master",
          "maxclass": "newobj",
          "patching_rect": [
            440,
            375,
            100,
            22
          ],
          "text": "line~ 0."
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
          "id": "help",
          "maxclass": "comment",
          "patching_rect": [
            25,
            625,
            1030,
            22
          ],
          "text": "Native groove~ time stretching. Mono duplicates to both channels; stereo stays stereo. Timeout: 500 ms."
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
          "text": "Keep stretch_time_engine.js beside this patch. All performance controls stay in Processing."
        }
      },
      {
        "box": {
          "id": "groove",
          "maxclass": "newobj",
          "text": "groove~ #0-stretch 2 @loop 1 @timestretch 1 @quality better @mode basic",
          "patching_rect": [
            25,
            320,
            570,
            22
          ]
        }
      },
      {
        "box": {
          "id": "speed",
          "maxclass": "newobj",
          "text": "line~ 0.",
          "patching_rect": [
            25,
            285,
            100,
            22
          ]
        }
      },
      {
        "box": {
          "id": "positionSnapshot",
          "maxclass": "newobj",
          "text": "snapshot~ 50",
          "patching_rect": [
            700,
            375,
            130,
            22
          ]
        }
      },
      {
        "box": {
          "id": "positionMessage",
          "maxclass": "newobj",
          "text": "prepend position",
          "patching_rect": [
            700,
            415,
            150,
            22
          ]
        }
      },
      {
        "box": {
          "id": "input",
          "maxclass": "inlet",
          "patching_rect": [
            20,
            15,
            30,
            30
          ]
        }
      },
      {
        "box": {
          "id": "audio0",
          "maxclass": "outlet",
          "patching_rect": [
            20,
            740,
            30,
            30
          ]
        }
      },
      {
        "box": {
          "id": "audio1",
          "maxclass": "outlet",
          "patching_rect": [
            240,
            740,
            30,
            30
          ]
        }
      },
      {
        "box": {
          "id": "feedbackOut",
          "maxclass": "outlet",
          "patching_rect": [
            700,
            740,
            30,
            30
          ]
        }
      }
    ],
    "lines": [
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
            "feedbackOut",
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
            "audio0",
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
            "audio1",
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
            "groove",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "js",
            6
          ],
          "destination": [
            "speed",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "speed",
            0
          ],
          "destination": [
            "groove",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "groove",
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
            "groove",
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
            "groove",
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
            "groove",
            2
          ],
          "destination": [
            "positionSnapshot",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "positionSnapshot",
            0
          ],
          "destination": [
            "positionMessage",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "positionMessage",
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
            "input",
            0
          ],
          "destination": [
            "js",
            0
          ]
        }
      }
    ]
  }
}