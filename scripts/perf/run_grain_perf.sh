#!/usr/bin/env bash
# Perf helper: capture a Flutter profile timeline while exercising the AtmosphericBackground grain overlay.
# Usage: ./scripts/perf/run_grain_perf.sh <device_id>
# Requires: Flutter SDK, an attached device or emulator, and permission to write to artifacts/.

set -euo pipefail
device=${1:-}
outdir="artifacts"
mkdir -p "$outdir"
if [ -z "$device" ]; then
  echo "No device id provided. Listing available devices..."
  flutter devices
  echo "Run again with a device id: ./scripts/perf/run_grain_perf.sh <device-id>"
  exit 2
fi

echo "Starting profile run on device $device"
# Run app in profile mode and capture trace-skia output.
tracefile="$outdir/grain_perf.timeline"
logfile="$outdir/grain_perf.log"

# Run flutter with trace-skia enabled; user should exercise the app (scroll dashboard, trigger animations)
flutter run --profile -d "$device" --trace-skia > "$logfile" 2>&1 &
FLUTTER_PID=$!

echo "App running (PID=$FLUTTER_PID). Exercise the app on device now for ~20 seconds to capture frames."
sleep 20

echo "Sending SIGINT to flutter run to finish and flush traces"
kill -SIGINT "$FLUTTER_PID" || true
sleep 2

# Attempt to locate the trace-skia output in the log (depends on engine behavior)
if grep -q "Timeline" "$logfile"; then
  echo "Trace output detected in log. Copying to $tracefile"
  # extract approximate trace snippets (best-effort)
  grep "TraceEvent" "$logfile" > "$tracefile" || true
else
  echo "No trace found in log. Please use Flutter DevTools Timeline to capture a full profile."
fi

echo "Perf run complete. Logs: $logfile, trace (best-effort): $tracefile"

echo "Note: For deterministic capture, run in profile mode on a physical device and use DevTools Timeline to export a full timeline." 
