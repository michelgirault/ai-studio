#!/bin/bash

#run blacklist 
BLACKLIST_FILE=$(cat <<ENDFILE
blacklist nouveau
options nouveau modeset=0
ENDFILE
)
MODPROBE_FILE=$(cat <<ENDFILE
nvidia
nvidia_vgpu_vfio
ENDFILE
)
echo "${MODPROBE_FILE}" > /etc/modules-load.d/nvidia.conf
echo "${BLACKLIST_FILE}" > /etc/modprobe.d/blacklist-nouveau.conf

sleep 30s
#install licensing

NVIDIA_GRIDD_CONFIG='U2VydmVyQWRkcmVzcz1udmlkaWFsaWMudnVsdHJsYWJzLmNvbQpGZWF0dXJlVHlwZT0xCkVuYWJsZVVJPUZBTFNFCkxpY2Vuc2VIb3N0SWQ9e3tNQUNIRVJFfX0K'
NVIDIA_TOKEN='ZXlKaGJHY2lPaUpTVXpJMU5pSXNJblI1Y0NJNklrcFhWQ0o5LmV5SnFkR2tpT2lJeE1qWmlPRGN5WVMxa01ETm1MVFEyWWpFdE9UbGxZUzA1WkRrNU5tWTBOVFl3WVdZaUxDSnBjM01pT2lKT1RGTWdVMlZ5ZG1salpTQkpibk4wWVc1alpTSXNJbUYxWkNJNklrNU1VeUJNYVdObGJuTmxaQ0JEYkdsbGJuUWlMQ0pwWVhRaU9qRTJOVFEzTlRJNU5qTXNJbTVpWmlJNk1UWTFORGMxTWprMk15d2laWGh3SWpveU1ETXpORFEwTVRZekxDSjFjR1JoZEdWZmJXOWtaU0k2SWtGQ1UwOU1WVlJGSWl3aWMyTnZjR1ZmY21WbVgyeHBjM1FpT2xzaU9Ua3lNVFJrWW1RdE9UVTJPQzAwTURVMUxXSmtNamN0WldJeU1EWTRaR1psTXpNM0lsMHNJbVoxYkdacGJHeHRaVzUwWDJOc1lYTnpYM0psWmw5c2FYTjBJanBiWFN3aWMyVnlkbWxqWlY5cGJuTjBZVzVqWlY5amIyNW1hV2QxY21GMGFXOXVJanA3SW01c2MxOXpaWEoyYVdObFgybHVjM1JoYm1ObFgzSmxaaUk2SWpBMVptSmlZMlJsTFRobU1HWXROREEyTXkxaVl6YzJMVFZqTnpReE5XSmxNV0poT1NJc0luTjJZMTl3YjNKMFgzTmxkRjlzYVhOMElqcGJleUpwWkhnaU9qQXNJbVJmYm1GdFpTSTZJa1JNVXlJc0luTjJZMTl3YjNKMFgyMWhjQ0k2VzNzaWMyVnlkbWxqWlNJNkltRjFkR2dpTENKd2IzSjBJam8wTkROOUxIc2ljMlZ5ZG1salpTSTZJbXhsWVhObElpd2ljRzl5ZENJNk5EUXpmVjE5WFN3aWJtOWtaVjkxY214ZmJHbHpkQ0k2VzNzaWFXUjRJam93TENKMWNtd2lPaUp1ZG1sa2FXRnNhV011ZG5Wc2RISnNZV0p6TG1OdmJTSXNJblZ5YkY5eGNpSTZJbTUyYVdScFlXeHBZeTUyZFd4MGNteGhZbk11WTI5dElpd2ljM1pqWDNCdmNuUmZjMlYwWDJsa2VDSTZNSDFkZlN3aWMyVnlkbWxqWlY5cGJuTjBZVzVqWlY5d2RXSnNhV05mYTJWNVgyTnZibVpwWjNWeVlYUnBiMjRpT25zaWMyVnlkbWxqWlY5cGJuTjBZVzVqWlY5d2RXSnNhV05mYTJWNVgyMWxJanA3SW0xdlpDSTZJbVV6TjJJek4yRmxZV0l6TldRMll6SXlPV0UyTURabFlXUXlNMlU0T0dZM1pHUTFNVGhpT0RBMU1XTm1ORFE1TmpneFpXSXpORGc1TlRBeU4yVm1NV1UwWlRZNU9UZGhOak0zTWpVeU1EZzRaakpqTXpnMVlqUTFaV0ppTURabVlUZ3pOall4TnpVMFl6UmlaV1JpTmpOa1pHWTFOamszTnpBNU5XWXdNbVppWVdVeE9XUmpNek5pTlRaaFlXVmhZalV4WWpOa04yWTRNRGcxTXpObU5ETTROR0UyTW1KaU1qQm1OVEJtTlROa01UUXlOakUyTlRZd1ltWmlZakEwTVRGa01HUmlOR0l4TW1Kak1ESmpaR0ZrWWpZMVlURmtNREV4TnpJMFpUTmpZVFZtT1dVNE1XWTFPR1kzWkRSbVpXVmtZek5qTUdNNE16WmxZekJqT1dKaU0yTXpZVGMzWXpabE1XUTNOR0ptWldRME1tVXpPVGczWXpJeE5XWm1OV00wTXpjell6bG1OR05rTm1ZelpXUXlOMkkyT1dFNE9USm1aRGcyTUdNelptTmhZMkUyT0dJNFpUUXdabUprWlRneE56TmxNVEZsTnpCbE4yRmpZakU0WkRjeE9HSXlObVkxTlRnek56ZGhZMlprWVRobE1XVTROVFJqTldVMU1EWmhZbU0xWW1NeFpqRTVOV1ZsT1RBell6Z3hPR000WkRVMU1XSTVNekl6TWpnMVlqQmpObVF5TnpZeVkyWXlNbVEwWmpVMVlUYzNZak00TURreU9EazBObVJpTW1Rd056UTFOemRtWkdFek1ETmxZalU0TkRBMlpEbGpOalJpWkRZeU5UaGpOamM1WVRNM01qUXhNV0k0TldJeE9HTTVOek0xTjJSa01EYzFJaXdpWlhod0lqbzJOVFV6TjMwc0luTmxjblpwWTJWZmFXNXpkR0Z1WTJWZmNIVmliR2xqWDJ0bGVWOXdaVzBpT2lJdExTMHRMVUpGUjBsT0lGQlZRa3hKUXlCTFJWa3RMUzB0TFZ4dVRVbEpRa2xxUVU1Q1oydHhhR3RwUnpsM01FSkJVVVZHUVVGUFEwRlJPRUZOU1VsQ1EyZExRMEZSUlVFME0zTXpjbkZ6TVRGelNYQndaMkp4TUdvMlNWeHVPVGt4VW1rMFFsSjZNRk5YWjJWek1HbFdRVzQzZURWUFlWcGxiVTU1VldkcFVFeEVhR0pTWlhWM1lqWm5NbGxZVmsxVEt6SXlVR1E1VjJ3elExWTRRMXh1S3pZMFdqTkVUekZoY1RaeVZXSlFXQ3RCYUZSUU1FOUZjR2wxZVVReFJERlFVbEZ0Um14WlRDczNRa0pJVVRJd2MxTjJRVXhPY21KYVlVaFJSVmhLVDF4dVVFdFlOVFpDT1ZrNU9WUXJOMk5RUVhsRVluTkVTblY2ZHpaa09HSm9NVEIyS3pGRE5EVm9PRWxXTHpGNFJHTTRiakI2Vnpnck1HNTBjSEZLVERsb1oxeHVkeTk1YzNCdmRVOVJVSFpsWjFoUWFFaHVSRzV5VEVkT1kxbHpiVGxXWnpObGN5OWhhbWcyUmxSR05WRmhjbmhpZDJaSFZqZHdRVGhuV1hsT1ZsSjFWRnh1U1hsb1lrUkhNRzVaY3pocE1WQldZV1EzVDBGcmIyeEhNbmt3U0ZKWVpqbHZkMUJ5VjBWQ2RHNUhVemxaYkdwSFpXRk9lVkZTZFVaeldYbFlUbGd6VVZ4dVpGRkpSRUZSUVVKY2JpMHRMUzB0UlU1RUlGQlZRa3hKUXlCTFJWa3RMUzB0TFNJc0ltdGxlVjl5WlhSbGJuUnBiMjVmYlc5a1pTSTZJa3hCVkVWVFZGOVBUa3haSW4xOS5xbDRpeDhEN24wY2Z3OXVQWmpEazlTRnVzU3lOczEtdVpIVzNKT190emtOX19rSmxtZDgtbHJKX3pNRmJwQXBZMFBsTThmWlFYNFlHNWJHMlZkbDNkSTF3WFNIX0hLV2VDa1JtTnVZRVZKY2UwNHR2OEZCWnFscDB1WjdUSE9JLW82NF96RTlpNDJBdFJlU0d1dzUwb2U2UV9FRl8zaVdqVlRiNEZ0MGVIOHJGVmhpSTZzeFRoN3hadGVNdmtzWllBcHVZbUJ1TGNkd0xFWWFTbUNKX0xSZlk5YW95ZldVbktKSWwxSm8wUmtiNWZyeGp5cG5OeWt1T2ZFdXlyUEdvSHQtWHZ0NlhyX3dpVVNOd3dZdUJDUnZuNjlWV3YxUjdhb2FoenAteWt4Smx5aW9YcV91X0Q0c1lLWFJia2d3Y19ESGlkbWJTVDVqcThjSXZQWS13NFE='
mkdir -p /etc/nvidia/ClientConfigToken
echo "${NVIDIA_GRIDD_CONFIG}" | base64 -d | sed 's|{{ '{{' }}MACHERE}}|{{sub.SUBID}}|' > /etc/nvidia/gridd.conf
echo "${NVIDIA_TOKEN}" | base64 -d > /etc/nvidia/ClientConfigToken/nvidialic.vultrlabs.com

#install repo for gpu
APPREPO_KEY=$(cat <<ENDFILE
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v2.0.22 (GNU/Linux)

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
SSmnWHkcE8C70A==
=ynen
-----END PGP PUBLIC KEY BLOCK-----
ENDFILE
)
echo "deb [signed-by=/usr/share/keyrings/vultr-apprepo.gpg] https://apprepo.vultr.com/debian universal main" > /etc/apt/sources.list.d/vultr-apprepo.list
echo "${APPREPO_KEY}" | gpg --dearmor > /usr/share/keyrings/vultr-apprepo.gpg
apt update -y

