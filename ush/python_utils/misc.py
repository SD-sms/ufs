#!/usr/bin/env python3

import re


def uppercase(s):
    """Converts a given string to uppercase

    Args:
        s (str): The string to change to uppercase
    Returns:
        Uppercased string
    """

    return s.upper()


def lowercase(s):
    """Converts a given string to lowercase

    Args:
        s (str): The string to change to lowercase
    Returns:
        Lowercased string
    """

    return s.lower()


def find_pattern_in_str(pattern, source):
    """Finds a regular expression (regex) pattern in a string

    Args:
        pattern (str): Regex pattern
        source  (str): Text string to search for regex pattern
    Returns:
        A tuple of matched groups or None
    """
    pattern = re.compile(pattern)
    for match in re.finditer(pattern, source):
        return match.groups()
    return None


def find_pattern_in_file(pattern, file_name):
    """Finds a regular expression (regex) pattern in a file

    Args:
        pattern   (str): Regex pattern
        file_name (str): Name of text file
    Returns:
        A tuple of matched groups or None
    """
    pattern = re.compile(pattern)
    with open(file_name) as f:
        for line in f:
            for match in re.finditer(pattern, line):
                return match.groups()
    return None
