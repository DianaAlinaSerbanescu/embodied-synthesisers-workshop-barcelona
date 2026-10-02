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
      750
    ],
    "default_fontsize": 12.0,
    "default_fontname": "Arial",
    "boxes": [
      {
        "box": {
          "id": "title",
          "maxclass": "comment",
          "patching_rect": [
            30,
            20,
            800,
            22
          ],
          "fontsize": 20.0,
          "text": "EMBODIED COLORATURA \u2014 A0 VOWEL / A1 PITCH"
        }
      },
      {
        "box": {
          "id": "info",
          "maxclass": "comment",
          "patching_rect": [
            30,
            55,
            1000,
            22
          ],
          "text": "Processing controls: D enable, 1/2 select sensor, R/S calibrate, M/Q mute voice."
        }
      },
      {
        "box": {
          "id": "info2",
          "maxclass": "comment",
          "patching_rect": [
            30,
            80,
            1000,
            22
          ],
          "text": "A0: vowel + gesture timbre. A1: C4\u2013F6 (262\u20131397 Hz). High-register resonance tuning."
        }
      },
      {
        "box": {
          "id": "js",
          "maxclass": "newobj",
          "patching_rect": [
            30,
            220,
            620,
            22
          ],
          "text": "js coloratura_engine.js"
        }
      },
      {
        "box": {
          "id": "voice0",
          "maxclass": "newobj",
          "patching_rect": [
            30,
            300,
            240,
            22
          ],
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
              900,
              650
            ],
            "default_fontsize": 12.0,
            "default_fontname": "Arial",
            "boxes": [
              {
                "box": {
                  "id": "in",
                  "maxclass": "inlet",
                  "patching_rect": [
                    30,
                    30,
                    30,
                    22
                  ]
                }
              },
              {
                "box": {
                  "id": "unpack",
                  "maxclass": "newobj",
                  "patching_rect": [
                    30,
                    70,
                    690,
                    22
                  ],
                  "text": "unpack f f f f f f f f f"
                }
              },
              {
                "box": {
                  "id": "saw",
                  "maxclass": "newobj",
                  "patching_rect": [
                    30,
                    225,
                    95,
                    22
                  ],
                  "text": "saw~ 261.625565"
                }
              },
              {
                "box": {
                  "id": "pack0",
                  "maxclass": "newobj",
                  "patching_rect": [
                    180,
                    115,
                    95,
                    22
                  ],
                  "text": "pack 0. 40"
                }
              },
              {
                "box": {
                  "id": "line0",
                  "maxclass": "newobj",
                  "patching_rect": [
                    180,
                    155,
                    95,
                    22
                  ],
                  "text": "line~ 300"
                }
              },
              {
                "box": {
                  "id": "q0",
                  "maxclass": "newobj",
                  "patching_rect": [
                    275,
                    205,
                    95,
                    22
                  ],
                  "text": "/~ 80.0"
                }
              },
              {
                "box": {
                  "id": "filter0",
                  "maxclass": "newobj",
                  "patching_rect": [
                    180,
                    260,
                    185,
                    22
                  ],
                  "text": "reson~ 0.8 300 3.75"
                }
              },
              {
                "box": {
                  "id": "pack1",
                  "maxclass": "newobj",
                  "patching_rect": [
                    395,
                    115,
                    95,
                    22
                  ],
                  "text": "pack 0. 40"
                }
              },
              {
                "box": {
                  "id": "line1",
                  "maxclass": "newobj",
                  "patching_rect": [
                    395,
                    155,
                    95,
                    22
                  ],
                  "text": "line~ 870"
                }
              },
              {
                "box": {
                  "id": "q1",
                  "maxclass": "newobj",
                  "patching_rect": [
                    490,
                    205,
                    95,
                    22
                  ],
                  "text": "/~ 100.0"
                }
              },
              {
                "box": {
                  "id": "filter1",
                  "maxclass": "newobj",
                  "patching_rect": [
                    395,
                    260,
                    185,
                    22
                  ],
                  "text": "reson~ 0.5 870 8.7"
                }
              },
              {
                "box": {
                  "id": "pack2",
                  "maxclass": "newobj",
                  "patching_rect": [
                    610,
                    115,
                    95,
                    22
                  ],
                  "text": "pack 0. 40"
                }
              },
              {
                "box": {
                  "id": "line2",
                  "maxclass": "newobj",
                  "patching_rect": [
                    610,
                    155,
                    95,
                    22
                  ],
                  "text": "line~ 2240"
                }
              },
              {
                "box": {
                  "id": "q2",
                  "maxclass": "newobj",
                  "patching_rect": [
                    705,
                    205,
                    95,
                    22
                  ],
                  "text": "/~ 140.0"
                }
              },
              {
                "box": {
                  "id": "filter2",
                  "maxclass": "newobj",
                  "patching_rect": [
                    610,
                    260,
                    185,
                    22
                  ],
                  "text": "reson~ 0.3 2240 16.0"
                }
              },
              {
                "box": {
                  "id": "envpack",
                  "maxclass": "newobj",
                  "patching_rect": [
                    30,
                    330,
                    110,
                    22
                  ],
                  "text": "pack 0. 20."
                }
              },
              {
                "box": {
                  "id": "env",
                  "maxclass": "newobj",
                  "patching_rect": [
                    30,
                    375,
                    100,
                    22
                  ],
                  "text": "line~ 0."
                }
              },
              {
                "box": {
                  "id": "sum",
                  "maxclass": "newobj",
                  "patching_rect": [
                    310,
                    330,
                    50,
                    22
                  ],
                  "text": "+~"
                }
              },
              {
                "box": {
                  "id": "sum2",
                  "maxclass": "newobj",
                  "patching_rect": [
                    310,
                    375,
                    50,
                    22
                  ],
                  "text": "+~"
                }
              },
              {
                "box": {
                  "id": "amp",
                  "maxclass": "newobj",
                  "patching_rect": [
                    310,
                    425,
                    50,
                    22
                  ],
                  "text": "*~"
                }
              },
              {
                "box": {
                  "id": "out",
                  "maxclass": "outlet",
                  "patching_rect": [
                    310,
                    485,
                    30,
                    22
                  ]
                }
              },
              {
                "box": {
                  "id": "desc",
                  "maxclass": "comment",
                  "patching_rect": [
                    30,
                    545,
                    750,
                    22
                  ],
                  "text": "A1: C4\u2013F6 pitch. A0: vowel and gate. F1 follows high pitch; F2 supports its second harmonic."
                }
              },
              {
                "box": {
                  "id": "bwpack0",
                  "maxclass": "newobj",
                  "text": "pack 0. 40",
                  "patching_rect": [
                    285,
                    115,
                    100,
                    22
                  ]
                }
              },
              {
                "box": {
                  "id": "bwline0",
                  "maxclass": "newobj",
                  "text": "line~ 80",
                  "patching_rect": [
                    285,
                    155,
                    100,
                    22
                  ]
                }
              },
              {
                "box": {
                  "id": "bwpack1",
                  "maxclass": "newobj",
                  "text": "pack 0. 40",
                  "patching_rect": [
                    500,
                    115,
                    100,
                    22
                  ]
                }
              },
              {
                "box": {
                  "id": "bwline1",
                  "maxclass": "newobj",
                  "text": "line~ 100",
                  "patching_rect": [
                    500,
                    155,
                    100,
                    22
                  ]
                }
              },
              {
                "box": {
                  "id": "bwpack2",
                  "maxclass": "newobj",
                  "text": "pack 0. 40",
                  "patching_rect": [
                    715,
                    115,
                    100,
                    22
                  ]
                }
              },
              {
                "box": {
                  "id": "bwline2",
                  "maxclass": "newobj",
                  "text": "line~ 140",
                  "patching_rect": [
                    715,
                    155,
                    100,
                    22
                  ]
                }
              },
              {
                "box": {
                  "id": "pitchpack",
                  "maxclass": "newobj",
                  "text": "pack 261.625565 40",
                  "patching_rect": [
                    30,
                    115,
                    140,
                    22
                  ]
                }
              },
              {
                "box": {
                  "id": "pitchline",
                  "maxclass": "newobj",
                  "text": "line~ 261.625565",
                  "patching_rect": [
                    30,
                    160,
                    130,
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
                    "unpack",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "unpack",
                    0
                  ],
                  "destination": [
                    "pack0",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "pack0",
                    0
                  ],
                  "destination": [
                    "line0",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "line0",
                    0
                  ],
                  "destination": [
                    "q0",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "q0",
                    0
                  ],
                  "destination": [
                    "filter0",
                    3
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "line0",
                    0
                  ],
                  "destination": [
                    "filter0",
                    2
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "saw",
                    0
                  ],
                  "destination": [
                    "filter0",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "unpack",
                    1
                  ],
                  "destination": [
                    "pack1",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "pack1",
                    0
                  ],
                  "destination": [
                    "line1",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "line1",
                    0
                  ],
                  "destination": [
                    "q1",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "q1",
                    0
                  ],
                  "destination": [
                    "filter1",
                    3
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "line1",
                    0
                  ],
                  "destination": [
                    "filter1",
                    2
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "saw",
                    0
                  ],
                  "destination": [
                    "filter1",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "unpack",
                    2
                  ],
                  "destination": [
                    "pack2",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "pack2",
                    0
                  ],
                  "destination": [
                    "line2",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "line2",
                    0
                  ],
                  "destination": [
                    "q2",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "q2",
                    0
                  ],
                  "destination": [
                    "filter2",
                    3
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "line2",
                    0
                  ],
                  "destination": [
                    "filter2",
                    2
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "saw",
                    0
                  ],
                  "destination": [
                    "filter2",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "unpack",
                    4
                  ],
                  "destination": [
                    "envpack",
                    1
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "unpack",
                    3
                  ],
                  "destination": [
                    "envpack",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "envpack",
                    0
                  ],
                  "destination": [
                    "env",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "filter0",
                    0
                  ],
                  "destination": [
                    "sum",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "filter1",
                    0
                  ],
                  "destination": [
                    "sum",
                    1
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "sum",
                    0
                  ],
                  "destination": [
                    "sum2",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "filter2",
                    0
                  ],
                  "destination": [
                    "sum2",
                    1
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "sum2",
                    0
                  ],
                  "destination": [
                    "amp",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "env",
                    0
                  ],
                  "destination": [
                    "amp",
                    1
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "amp",
                    0
                  ],
                  "destination": [
                    "out",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "unpack",
                    5
                  ],
                  "destination": [
                    "bwpack0",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "bwpack0",
                    0
                  ],
                  "destination": [
                    "bwline0",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "bwline0",
                    0
                  ],
                  "destination": [
                    "q0",
                    1
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "unpack",
                    6
                  ],
                  "destination": [
                    "bwpack1",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "bwpack1",
                    0
                  ],
                  "destination": [
                    "bwline1",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "bwline1",
                    0
                  ],
                  "destination": [
                    "q1",
                    1
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "unpack",
                    7
                  ],
                  "destination": [
                    "bwpack2",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "bwpack2",
                    0
                  ],
                  "destination": [
                    "bwline2",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "bwline2",
                    0
                  ],
                  "destination": [
                    "q2",
                    1
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "unpack",
                    8
                  ],
                  "destination": [
                    "pitchpack",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "pitchpack",
                    0
                  ],
                  "destination": [
                    "pitchline",
                    0
                  ]
                }
              },
              {
                "patchline": {
                  "source": [
                    "pitchline",
                    0
                  ],
                  "destination": [
                    "saw",
                    0
                  ]
                }
              }
            ]
          },
          "text": "p voice0"
        }
      },
      {
        "box": {
          "id": "vlabel0",
          "maxclass": "comment",
          "patching_rect": [
            30,
            335,
            330,
            22
          ],
          "text": "One centered voice / A1: C4\u2013F6"
        }
      },
      {
        "box": {
          "id": "pan00",
          "maxclass": "newobj",
          "patching_rect": [
            30,
            385,
            125,
            22
          ],
          "text": "*~ 0.707107"
        }
      },
      {
        "box": {
          "id": "pan01",
          "maxclass": "newobj",
          "patching_rect": [
            175,
            385,
            125,
            22
          ],
          "text": "*~ 0.707107"
        }
      },
      {
        "box": {
          "id": "clip0",
          "maxclass": "newobj",
          "patching_rect": [
            110,
            490,
            150,
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
            410,
            490,
            150,
            22
          ],
          "text": "clip~ -0.95 0.95"
        }
      },
      {
        "box": {
          "id": "feedback",
          "maxclass": "newobj",
          "patching_rect": [
            730,
            300,
            290,
            22
          ],
          "text": "prepend /formants/coloratura/feedback"
        }
      },
      {
        "box": {
          "id": "help",
          "maxclass": "comment",
          "patching_rect": [
            30,
            625,
            960,
            22
          ],
          "text": "Keep coloratura_engine.js beside this patch. Synthesized soprano-inspired timbre."
        }
      },
      {
        "box": {
          "id": "help2",
          "maxclass": "comment",
          "patching_rect": [
            30,
            650,
            1020,
            22
          ],
          "text": "Audio device: Max > Settings > Audio Status. Performance controls and formant display are in Processing."
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
            "js",
            0
          ],
          "destination": [
            "voice0",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "voice0",
            0
          ],
          "destination": [
            "pan00",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "voice0",
            0
          ],
          "destination": [
            "pan01",
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
            2
          ],
          "destination": [
            "feedback",
            0
          ]
        }
      },
      {
        "patchline": {
          "source": [
            "feedback",
            0
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
            "pan00",
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
            "pan01",
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