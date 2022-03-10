#/bin/bash
START=$(date +%s)

ansible-playbook -i inventories/kne/hosts plays/cluster-setup-with-k3s-control-cluster.yaml --vault-password-file=vault_password -v --skip-tags=k3s_setup_cleanup_nodes
ansible-playbook -i inventories/kne/hosts plays/upgrade-k3s-control-cluster.yaml --vault-password-file=vault_password -v
ansible-playbook -i inventories/kne/hosts plays/upgrade-rancher.yaml --vault-password-file=vault_password -v

END=$(date +%s)
DIFF=$(echo "$END - $START" | bc)
echo ""
echo ""
echo -e "\e[31mTook $(printf %.1f "$((10**3 * DIFF/60))e-3") minutes to execute\e[0m"
echo ""