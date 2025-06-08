note_frequencies = {
    "C": 261.8,  # DO
    "D": 294.3,  # RE
    "E": 330.9,  # MI
    "F": 348.1,  # FA
    "G": 391.0,  # SOL
    "A": 442.0,  # LA
    "B": 493.5,  # SI
    "C#": 277.0,
    "rest": 100000,
}

melody_data = [
    ("D", 10230),
    ("rest", 1),
    ("D", 10230),
    ("E", 9100),
    ("F", 8650),
    ("A", 6800),
    ("G", 7700),
    ("A", 6800),
    ("C", 11500),
    ("D", 10230),
    ("E", 9100),
    ("F", 8650),
    ("E", 9100),
    ("G", 7700),
    ("A", 6800),
    ("G", 7700),
    ("F", 8650),
    ("rest", 1),
    ("F", 8650),
    ("rest", 1),
    ("F", 8650),
    ("rest", 1),
    ("F", 8650),
    ("A", 6800),
    ("rest", 1),
    ("A", 6800),
    ("G", 7700),
    ("F", 8650),
    ("A", 6800),
    ("rest", 1),
    ("A", 6800),
    ("rest", 1),
    ("A", 6800),
    ("G", 7700),
    ("A", 6800),
    ("G", 7700),
    ("F", 8650),
    ("rest", 1),
    ("F", 8650),
    ("rest", 1),
    ("F", 8650),
    ("rest", 1),
    ("F", 8650),
    ("A", 6800),
    ("rest", 1),
    ("A", 6800),
    ("G", 7700),
    ("F", 8650),
    ("A", 6800),
    ("rest", 1),
    ("A", 6800),
    ("rest", 1),
    ("A", 6800),
    ("C#", 10800),
    ("rest", 1),
    ("C#", 10800),
    ("rest", 1),
    ("C#", 10800),
    ("F", 8650),
    ("rest", 1),
    ("F", 8650),
    ("rest", 1),
    ("F", 8650),
    ("A", 6800),
    ("rest", 1),
    ("A", 6800),
    ("G", 7700),
    ("F", 8650),
    ("A", 6800),
    ("rest", 1),
    ("A", 6800),
    ("rest", 1),
    ("A", 6800),
    ("G", 7700),
    ("C", 11500),
    ("G", 7700),
    ("C#", 10800),
    ("D", 10230),
]

print(".align 3")
print("melody:")
for note, duration_value in melody_data:
    freq = note_frequencies.get(note)
    if freq == 0.0:
        print(f"    .quad {duration_value}, 0    // rest")
    elif freq:
        freq_int = round(freq * 0.25)  # duration is fixed at 1s
        print(f"    .quad {duration_value}, {freq_int}    // {note}")
    else:
        print(f"    // Unknown note: {note}")
