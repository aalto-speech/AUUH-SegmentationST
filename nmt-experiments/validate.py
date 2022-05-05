#!/usr/bin/env python3
# Copying the official evaluation script
# so that we can use e.g. F1 score for validation

import evaluate as ev

def get_overall_stats(goldfile, guessfile)
    gold_data = ev.read_tsv(goldfile, False)
    guess_data = (guessfile, False)  # only second column is needed
    assert len(gold_data["segments"]) == len(guess_data["segments"]), \
        "gold and guess tsvs do not have the same number of entries"
    # levenshtein distance can be computed separately for each pair
    dists = [ev.distance(gold, guess)
             for gold, guess
             in zip(gold_data["segments"], guess_data["segments"])]
    # the values needed for P/R can also be broken down per-example
    n_overlaps = [ev.n_correct(gold, guess)
                  for gold, guess
                  in zip(gold_data["segments"], guess_data["segments"])]
    gold_lens = [len(gold.split("|")) for gold in gold_data["segments"]]
    pred_lens = [len(guess.split("|")) for guess in guess_data["segments"]]
    overall_stats = ev.compute_stats(dists, n_overlaps, gold_lens, pred_lens)
    return overall_stats

if __name__ == "__main__":
    import argparse
    import pathlib
    from char_detokenize import run_detokenization
    parser = argparse.ArgumentParser("Validate with official evaluation")
    parser.add_argument("gold", 
            help="The gold standard file to compare against", 
            type=pathlib.Path)
    parser.add_argument("decoded", 
            help="The validation decode output (with out .tsv formatting)",
            type = pathlib.Path)
    parser.add_argument("--measure_name", default="f_measure")
    args = parser.parse_args()
    guessfile = args.decoded.with_suffix("tsv")
    run_detokenization(
            translationfile=args.decoded, 
            metadatafile=args.gold, 
            outputfile=guessfile
    )
    stats = get_overall_stats(args.gold, guessfile)
    if args.measure_name == "distance":
        print(100. - stats["distance"])
    else:
        # f_measure here is the default:
        print(stats[args.measure_name])

