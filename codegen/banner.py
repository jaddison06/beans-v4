def banner(msg: str, uppercase: bool = True, hyphen_count: int = 10) -> str:
    hyphens = "-" * hyphen_count
    if uppercase:
        msg = msg.upper()
    return f"// {hyphens}{msg}{hyphens}\n\n"