#!/bin/bash

while read line; do
  ${line}
done < <$(find / -name "*.sh")
