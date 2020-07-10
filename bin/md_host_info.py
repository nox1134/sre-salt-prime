#!/usr/bin/env python3
# vim: set fileencoding=utf-8 :

r"""Create markdown table of host information:

sudo salt \* saltutil.sync_grains
sudo salt --out yaml \* grains.item lsb_distrib_description \
    meta-data:public-ipv4 fqdn_ip4 saltversion \
    | bin/md_host_info.py
"""

# Standard Libary
import datetime
import sys

# Third-party
import yaml


def format_columns(rows, sep=None, align=None):
    """Convert a list (rows) of lists (columns) to a formatted list of lines.
    When joined with newlines and printed, the output is similar to
    `column -t`.

    The optional align may be a list of alignment formatters.

    The last (right-most) column will not have any trailing whitespace so that
    it wraps as cleanly as possible.

    Based on MIT licensed:
    https://github.com/ClockworkNet/OpScripts/blob/master/opscripts/utils/v8.py

    Based on solution provided by antak in http://stackoverflow.com/a/12065663
    """
    lines = list()
    if sep is None:
        sep = "  "
    widths = [max(map(len, map(str, col))) for col in zip(*rows)]
    for row in rows:
        formatted = list()
        last_col = len(row) - 1
        for i, col in enumerate(row):
            # right alighed
            if align and align[i].lower() in (">", "r"):
                formatted.append(str(col).rjust(widths[i]))
            # center aligned
            elif align and align[i].lower() in ("^", "c"):
                col_formatted = str(col).center(widths[i])
                if i == last_col:
                    col_formatted = col_formatted.rstrip()
                formatted.append(col_formatted)
            # left aligned
            else:
                if i == last_col:
                    formatted.append(str(col))
                else:
                    formatted.append(str(col).ljust(widths[i]))
        lines.append(sep.join(formatted))
    return lines


def main():
    now = datetime.datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S UTC")
    data = yaml.safe_load(sys.stdin)
    print()
    align = ["r", "l", "c", "l", "l", "r"]
    rows = list()
    rows.append(
        [
            "Cnt",
            "Host",
            "Public IP",
            "Operating System",
            "Salt Version",
            "Days Up",
        ]
    )
    rows.append(
        [
            "--:",
            "----",
            ":-------:",
            "----------------",
            "------------",
            "------:",
        ]
    )
    i = 1
    for host in sorted(data.keys()):
        grains = data[host]
        uptime = grains["uptime_days"]
        count_f = "{: 3d}".format(i)
        if uptime > 90.0:
            b = "**"
        else:
            b = ""
        if "meta-data:public-ipv4" in grains:
            aws_ip = grains["meta-data:public-ipv4"]
        else:
            aws_ip = False
        if "fqdn_ip4" in grains:
            fqdn_ips = grains["fqdn_ip4"]
        else:
            fqdn_ips = False
        if aws_ip:
            ip_f = aws_ip
        elif fqdn_ips and fqdn_ips[0] and fqdn_ips[0] != "127.0.1.1":
            ip_f = fqdn_ips[0]
        else:
            ip_f = ""
        host_f = "`{}`".format(host)
        os_f = grains["lsb_distrib_description"]
        salt_f = "{}".format(grains["saltversion"])
        uptime_f = "{}{:.2f}{}".format(b, uptime, b)
        if grains == "Minion did not return. [Not connected]":
            print(host, "| *N/A* | *Not connected*")
            rows.append(
                [count_f, host_f, "*N/A*", "Not connected", "*N/A*" "*N/A*"]
            )
        else:
            rows.append([count_f, host_f, ip_f, os_f, salt_f, uptime_f])
        i += 1
    print("\n".join(format_columns(rows, " | ", align=align)))
    print()
    print("Generated {} via:".format(now))
    print("```shell")
    print("sudo salt \\* saltutil.sync_grains")
    print("sudo salt --out yaml \\* grains.item lsb_distrib_description \\")
    print("    meta-data:public-ipv4 fqdn_ip4 saltversion uptime_days \\")
    print("    | bin/md_host_info.py")
    print("```")
    print()


if __name__ == "__main__":
    main()
