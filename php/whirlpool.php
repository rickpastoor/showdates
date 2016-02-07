<?php
if (!$argv[1]) {
  echo "No input argument provided\n";
  return;
}

echo hash('whirlpool', $argv[1]);
