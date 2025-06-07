note_frequencies = {
    "C": 261.8,  # DO
    "D": 294.3,  # RE
    "E": 330.9,  # MI
    "F": 348.1,  # FA
    "G": 391.0,  # SOL
    "A": 442.0,  # LA
    "B": 493.5,  # SI
    "C#": 277.0,
    "rest": 5000,
}

melody_data = [
    ("D", 12600),
    ("rest", 1),
    ("D", 12600),
    ("E", 11200),
    ("F", 10600),
    ("A", 8500),
    ("G", 9400),
    ("A", 8500),
    ("C", 14300),
    ("D", 12600),
    ("E", 11200),
    ("F", 10600),
    ("E", 11200),
    ("G", 9400),
    ("A", 8500),
    ("G", 9400),
    ("F", 10600),
    ("rest", 1),
    ("F", 10600),
    ("rest", 1),
    ("F", 10600),
    ("rest", 1),
    ("F", 10600),
    ("A", 8500),
    ("rest", 1),
    ("A", 8500),
    ("G", 9400),
    ("F", 10600),
    ("A", 8500),
    ("rest", 1),
    ("A", 8500),
    ("rest", 1),
    ("A", 8500),
    ("G", 9400),
    ("A", 8500),
    ("G", 9400),
    ("F", 10600),
    ("rest", 1),
    ("F", 10600),
    ("rest", 1),
    ("F", 10600),
    ("rest", 1),
    ("F", 10600),
    ("A", 8500),
    ("rest", 1),
    ("A", 8500),
    ("G", 9400),
    ("F", 10600),
    ("A", 8500),
    ("rest", 1),
    ("A", 8500),
    ("rest", 1),
    ("A", 8500),
    ("C#", 14300),
    ("rest", 1),
    ("C#", 14300),
    ("rest", 1),
    ("C#", 14300),
    ("F", 10600),
    ("rest", 1),
    ("F", 10600),
    ("rest", 1),
    ("F", 10600),
    ("A", 8500),
    ("rest", 1),
    ("A", 8500),
    ("G", 9400),
    ("F", 10600),
    ("A", 8500),
    ("rest", 1),
    ("A", 8500),
    ("rest", 1),
    ("A", 8500),
    ("G", 9400),
    ("C", 14300),
    ("G", 9400),
    ("C#", 14300),
    ("D", 12600),
]

print(".align 3")
print("melody:")
for note, duration_value in melody_data:
    freq = note_frequencies.get(note)
    if freq == 0.0:
        print(f"    .quad {duration_value}, 0    // rest")
    elif freq:
        freq_int = round(freq * 0.5)  # duration is fixed at 1s
        print(f"    .quad {duration_value}, {freq_int}    // {note}")
    else:
        print(f"    // Unknown note: {note}")
