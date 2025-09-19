#!/usr/bin/env python3
# Read from stdin and Zalgo-ify
# By MetroWind <chris.corsair {AT} gmail>

import sys
import random

# Characters taken from http://str.blogsite.org/Zalgo.htm.
CHAR_UP = [
    "\u030d",
    "\u030e",
    "\u0304",
    "\u0305",
    "\u033f",
    "\u0311",
    "\u0306",
    "\u0310",
    "\u0352",
    "\u0357",
    "\u0351",
    "\u0307",
    "\u0308",
    "\u030a",
    "\u0342",
    "\u0343",
    "\u0344",
    "\u034a",
    "\u034b",
    "\u034c",
    "\u0303",
    "\u0302",
    "\u030c",
    "\u0350",
    "\u0300",
    "\u0301",
    "\u030b",
    "\u030f",
    "\u0312",
    "\u0313",
    "\u0314",
    "\u033d",
    "\u0309",
    "\u0363",
    "\u0364",
    "\u0365",
    "\u0366",
    "\u0367",
    "\u0368",
    "\u0369",
    "\u036a",
    "\u036b",
    "\u036c",
    "\u036d",
    "\u036e",
    "\u036f",
    "\u033e",
    "\u035b",
    "\u0346",
    "\u031a",
]

CHAR_MID = [
    "\u0315",
    "\u031b",
    "\u0340",
    "\u0341",
    "\u0358",
    "\u0321",
    "\u0322",
    "\u0327",
    "\u0328",
    "\u0334",
    "\u0335",
    "\u0336",
    "\u034f",
    "\u035c",
    "\u035d",
    "\u035e",
    "\u035f",
    "\u0360",
    "\u0362",
    "\u0338",
    "\u0337",
    "\u0361",
    "\u0489",
]

CHAR_DOWN = [
    "\u0316",
    "\u0317",
    "\u0318",
    "\u0319",
    "\u031c",
    "\u031d",
    "\u031e",
    "\u031f",
    "\u0320",
    "\u0324",
    "\u0325",
    "\u0326",
    "\u0329",
    "\u032a",
    "\u032b",
    "\u032c",
    "\u032d",
    "\u032e",
    "\u032f",
    "\u0330",
    "\u0331",
    "\u0332",
    "\u0333",
    "\u0339",
    "\u033a",
    "\u033b",
    "\u033c",
    "\u0345",
    "\u0347",
    "\u0348",
    "\u0349",
    "\u034d",
    "\u034e",
    "\u0353",
    "\u0354",
    "\u0355",
    "\u0356",
    "\u0359",
    "\u035a",
    "\u0323",
]

ZALGO_POS = ("up", "mid", "down")
ZALGO_CHARS = {"up": CHAR_UP, "mid": CHAR_MID, "down": CHAR_DOWN}

random.seed()


def randStr(charset, count, allow_repeat=True, return_list=True):
    """Randomly chooses a subset with `count' number of characters
    from `charset', and returns the resulting string.  If
    `allow_repeat' is False, a permutation is chosen.  If
    `return_list' is True, a list of chars is returned, otherwise a
    string is returned.
    """
    Result = list()
    if allow_repeat:
        for i in range(count):
            Result.append(random.choice(charset))
    else:
        Result = random.sample(charset, count)
        random.shuffle(Result)

    if return_list:
        return Result
    else:
        return "".join(Result)


def zalgo(orig_str, intensities, excludes=(" "), rand_intensity=True, allow_repeat=True):
    """Zalgo-ify `orig_str'.  `Intensityies' is a dict in the form of
    {"up": intense_up, "mid": intense_mid, "down":
    intense_down}.  "Intense_up" denotes the intensity of the
    up-going zalgo chars, etc.  If `rand_intensity' is False,
    "intense_up" number of up-going zalgo chars are used, etc.  If
    `rand_intensity' is True, a random number (but less than
    "intense_up") of up-going zalgo chars are used, etc.  If
    `allow_repeat' is True, repeating zalgo chars on one char in
    `orig_str' is possible.  Characters in `excludes' will not be
    zalgo-ified.
    """
    Result = []
    for OrigChar in orig_str:
        if OrigChar in excludes:
            Result.append(OrigChar)
        else:
            ZalgoCounts = {"up": 0, "down": 0, "mid": 0}
            for pos in ZALGO_POS:
                if rand_intensity:
                    ZalgoCounts[pos] = random.randint(0, intensities[pos])
                else:
                    ZalgoCounts[pos] = intensities[pos]

            Result.append(OrigChar)

            for pos in ZALGO_POS:
                Result += randStr(ZALGO_CHARS[pos], ZalgoCounts[pos], allow_repeat)

    return "".join(Result)


def main():
    Usage = "Usage: %prog [options]"

    import optparse

    OptParser = optparse.OptionParser(usage=Usage)

    OptParser.add_option(
        "-u",
        "--up-intensity",
        dest="IntenseUp",
        default=2,
        type="int",
        metavar="NUM",
        help="The number of Zalgo characters to put above"
        "the original character.  Default: %default",
    )
    OptParser.add_option(
        "-m",
        "--mid-intensity",
        dest="IntenseMid",
        default=1,
        type="int",
        metavar="NUM",
        help="The number of Zalgo characters to put at"
        "the original character.  Default: %default",
    )
    OptParser.add_option(
        "-d",
        "--down-intensity",
        dest="IntenseDown",
        default=5,
        type="int",
        metavar="NUM",
        help="The number of Zalgo characters to put below"
        "the original character.  Default: %default",
    )
    OptParser.add_option(
        "-f",
        "--fix-intensity",
        dest="Random",
        default=True,
        action="store_false",
        help="Don’t randomize the intensity.",
    )
    OptParser.add_option(
        "-e",
        "--excludes",
        dest="Excludes",
        default=" ",
        metavar="STR",
        help="Don’t Zalgo-ify characters in STR. " 'Default: "%default"',
    )

    (Opts, Args) = OptParser.parse_args()

    Intense = {"up": Opts.IntenseUp, "mid": Opts.IntenseMid, "down": Opts.IntenseDown}

    for Line in sys.stdin:
        print(zalgo(Line, Intense, tuple(Opts.Excludes), Opts.Random))
    return 0


if __name__ == "__main__":
    sys.exit(main())
