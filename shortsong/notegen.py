# Define your notes: (label, half_period in cycles)
notes = [
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
    ("rest",1),
    ("A", 8500),
    ("G", 9400),
    ("F", 10600),
    ("A", 8500),
    ("rest", 1),
    ("A", 8500),
    ("rest",1),
    ("A", 8500),
    ("G", 9400),
    ("A", 8500),
    ("G", 9400),
    ("F", 10600),
    ("rest",1),
    ("F", 10600),
    ("rest",1),
    ("F", 10600),
    ("rest",1),
    ("F", 10600),
    ("A", 8500),
    ("rest",1),
    ("A", 8500),
    ("G", 9400),
    ("F", 10600),
    ("A", 8500),
    ("rest",1),
    ("A", 8500),
    ("rest",1),
    ("A", 8500),
    ("C#", 14300),
    ("rest",1),
    ("C#", 14300),
    ("rest",1),
    ("C#", 14300),
    ("F", 10600),
    ("rest",1),
    ("F", 10600),
    ("rest",1),
    ("F", 10600),
    ("A", 8500),
    ("rest",1),
    ("A", 8500),
    ("G", 9400),
    ("F", 10600),
    ("A", 8500),
    ("rest",1),
    ("A", 8500),
    ("rest",1),
    ("A", 8500),
    ("G", 9400),
    ("C", 14300),
    ("G", 9400),
    ("C#", 14300),
    ("D", 12600),
]

# Durations
max_duration = 5000000
short_duration = 2000000

print(".align 3")
print("melody:")

for i, (label, half_period) in enumerate(notes):
    if half_period == 1:
        # Rest
        print(f"    .quad {half_period}, {50000}    // {label}")
        continue

    # Look around the current note
    prev_is_rest = i > 0 and notes[i - 1][0] == "rest"
    next_is_rest = i < len(notes) - 1 and notes[i + 1][0] == "rest"

    # If it's right before or after a rest, use short duration
    if prev_is_rest or next_is_rest:
        duration = short_duration
    else:
        duration = max_duration

    toggle_count = duration // (2 * half_period)
    print(f"    .quad {half_period}, {toggle_count:<5}    // {label}")
