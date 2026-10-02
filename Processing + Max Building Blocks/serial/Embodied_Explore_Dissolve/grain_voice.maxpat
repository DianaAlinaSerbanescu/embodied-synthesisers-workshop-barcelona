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
      800,
      660
    ],
    "default_fontsize": 12.0,
    "default_fontname": "Arial",
    "boxes": [
      {
        "box": {
          "id": "in",
          "maxclass": "newobj",
          "patching_rect": [
            30,
            35,
            70,
            22
          ],
          "text": "in 1"
        }
      },
      {
        "box": {
          "id": "trigger",
          "maxclass": "newobj",
          "patching_rect": [
            30,
            80,
            70,
            22
          ],
          "text": "t l b"
        }
      },
      {
        "box": {
          "id": "unmute",
          "maxclass": "message",
          "patching_rect": [
            200,
            80,
            65,
            22
          ],
          "text": "mute 0"
        }
      },
      {
        "box": {
          "id": "thispoly",
          "maxclass": "newobj",
          "patching_rect": [
            300,
            80,
            85,
            22
          ],
          "text": "thispoly~"
        }
      },
      {
        "box": {
          "id": "split",
          "maxclass": "newobj",
          "patching_rect": [
            30,
            130,
            70,
            22
          ],
          "text": "t l l"
        }
      },
      {
        "box": {
          "id": "pointerMsg",
          "maxclass": "message",
          "patching_rect": [
            250,
            185,
            110,
            22
          ],
          "text": "$1, $2 $3"
        }
      },
      {
        "box": {
          "id": "pointer",
          "maxclass": "newobj",
          "patching_rect": [
            250,
            235,
            70,
            22
          ],
          "text": "line~"
        }
      },
      {
        "box": {
          "id": "play",
          "maxclass": "newobj",
          "patching_rect": [
            250,
            285,
            130,
            22
          ],
          "text": "play~ #1 2"
        }
      },
      {
        "box": {
          "id": "phaseMsg",
          "maxclass": "message",
          "patching_rect": [
            30,
            185,
            110,
            22
          ],
          "text": "0., 1. $3"
        }
      },
      {
        "box": {
          "id": "phase",
          "maxclass": "newobj",
          "patching_rect": [
            30,
            235,
            70,
            22
          ],
          "text": "line~"
        }
      },
      {
        "box": {
          "id": "hann",
          "maxclass": "newobj",
          "patching_rect": [
            30,
            280,
            70,
            22
          ],
          "text": "cos~"
        }
      },
      {
        "box": {
          "id": "mute",
          "maxclass": "message",
          "patching_rect": [
            500,
            185,
            65,
            22
          ],
          "text": "mute 1"
        }
      },
      {
        "box": {
          "id": "init",
          "maxclass": "newobj",
          "patching_rect": [
            500,
            35,
            80,
            22
          ],
          "text": "loadbang"
        }
      },
      {
        "box": {
          "id": "mul0",
          "maxclass": "newobj",
          "patching_rect": [
            250,
            395,
            60,
            22
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "out0",
          "maxclass": "newobj",
          "patching_rect": [
            250,
            450,
            90,
            22
          ],
          "text": "out~ 1"
        }
      },
      {
        "box": {
          "id": "mul1",
          "maxclass": "newobj",
          "patching_rect": [
            430,
            395,
            60,
            22
          ],
          "text": "*~"
        }
      },
      {
        "box": {
          "id": "out1",
          "maxclass": "newobj",
          "patching_rect": [
            430,
            450,
            90,
            22
          ],
          "text": "out~ 2"
        }
      },
      {
        "box": {
          "id": "desc",
          "maxclass": "comment",
          "patching_rect": [
            30,
            530,
            745,
            22
          ],
          "text": "Each grain captures start/end/duration. Read speed is 1x; half-strength Hann window balances fourfold overlap."
        }
      },
      {
        "box": {
          "id": "hannScale",
          "maxclass": "newobj",
          "text": "*~ -0.25",
          "patching_rect": [
            30,
            325,
            85,
            22
          ]
        }
      },
      {
        "box": {
          "id": "hannOffset",
          "maxclass": "newobj",
          "text": "+~ 0.25",
          "patching_rect": [
            30,
            370,
            85,
            22
          ]
        }
      }
    ],
    "lines": [
      {
        "patchline": {
          "source": [
            "in",
            0
          ],
          "destination": [
            "trigger",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "trigger",
            1
          ],
          "destination": [
            "unmute",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "unmute",
            0
          ],
          "destination": [
            "thispoly",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "trigger",
            0
          ],
          "destination": [
            "split",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "split",
            1
          ],
          "destination": [
            "pointerMsg",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "pointerMsg",
            0
          ],
          "destination": [
            "pointer",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "pointer",
            0
          ],
          "destination": [
            "play",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "split",
            0
          ],
          "destination": [
            "phaseMsg",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "phaseMsg",
            0
          ],
          "destination": [
            "phase",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "phase",
            0
          ],
          "destination": [
            "hann",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "phase",
            1
          ],
          "destination": [
            "mute",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "mute",
            0
          ],
          "destination": [
            "thispoly",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "init",
            0
          ],
          "destination": [
            "mute",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "play",
            0
          ],
          "destination": [
            "mul0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "hannOffset",
            0
          ],
          "destination": [
            "mul0",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "mul0",
            0
          ],
          "destination": [
            "out0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "play",
            1
          ],
          "destination": [
            "mul1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "hannOffset",
            0
          ],
          "destination": [
            "mul1",
            1
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "mul1",
            0
          ],
          "destination": [
            "out1",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "hann",
            0
          ],
          "destination": [
            "hannScale",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "hannScale",
            0
          ],
          "destination": [
            "hannOffset",
            0
          ]
        }
      }
    ]
  }
}