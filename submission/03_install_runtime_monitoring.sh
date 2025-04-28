#!/bin/bash

# Step 12: Custom Falco Rule (Optional)
echo "Creating custom Falco rule..."
cat <<EOF >> /etc/falco/falco_rules.local.yaml
- rule: Sensitive file read
  desc: Detects attempts to read sensitive files
  condition: evt.type in (open) and fd.name startswith /etc/
  output: Sensitive file accessed
  priority: CRITICAL
EOF
echo "Custom Falco rule added."

# Step 13: Test Custom Falco Rule (Optional)
echo "Testing custom Falco rule..."
# Simulate a sensitive file read by accessing a file in /etc/
echo "Testing Falco rule..." > /etc/test_file.txt
echo "Simulated sensitive file read to trigger the custom rule."

# Step 14: Monitor Grafana for Custom Falco Rule (Optional)
echo "Checking Grafana for custom rule trigger..."
# The output should appear on your Grafana dashboard
echo "Check Grafana for the sensitive file access trigger."
