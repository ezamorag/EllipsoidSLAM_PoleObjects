function observations = get_observations(LRFrawdata)
trees = extract_poles(LRFrawdata);
observations.z = trees;
observations.m = size(trees,2);
