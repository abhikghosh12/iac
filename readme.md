# Neue Doku wird im Confluence gepflegt:

https://confluence.entw.bund.drv/confluence/display/ITAM/Aufsetzen+eines+Rancher+Clusters+mit+Hilfe+von+Ansible

# Alte Doku:
Es existieren mehrere [Ansible Roles](https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html) zum löschen und erstellen eines Rancher Clusters, sowie zum automatischen aufsetzen von Kubernetes Clustern (beides basierend auf K3S).

Um eine Rolle auszuführen, muss zunächst eine geeignete Umgebung existieren, auf der Ansible zur Vefügung steht. Dies ist glücklicherweise auf der VM v0002439.entw.bund.drv (adminhost) der Fall. Zusätzlich benötigt man ein Passwort zum entschlüsseln der sensiblen Daten (Rancher API Token). Dieses ist in der ENTW Keepass Datenbank hinterlegt. Zuletzt wird noch ein private key benötigt, der Zugriff auf die Zielsysteme hat. Aktuell existiert noch kein allgemeiner key, der für die Automatisierung hergenommen werden kann.

Um einen Cluster automatisiert aufzusetzen, geht man wie folgt vor:

1. Git Repository auf Provisionierungssystem clonen
1. Private Key in dem Ordner des geklonten Repositories ablegen. Per default wird nach einem Key namens id_rsa gesucht. Das Verhalten lässt sich über die ansible.cfg-Datei steuern.
1. Ansible playbook ausführen: *ansible-playbook -i inventories/**kne**/hosts plays/cluster-setup-with-k3s.yaml --ask-vault-pass*
1. Dabei ist der fettgedruckte Umgebungsname durch die anvisierte Umgebung zu ersetzen

Die folgende Tabelle bietet einen Überblick über die bisher existierenden Playbooks mitsamt einer kurzen Beschreibung, was dieses genau tut:

|Playbook   | Bedeutung  |
|---|---|
|cluster-setup-with-k3s.yaml   |Setzt einen auf K3S basierenden Cluster bestehend aus Master und Worker Knoten auf   |
|cluster-setup-with-k3s-control-cluster.yaml   |Setzt einen auf K3S basierenden Cluster bestehend aus Master und Worker Knoten auf und installiert darüber hinaus Rancher auf diesem Cluster   |
|upgrade-k3s.yaml   |Aktualisiert eine bestehende K3S Installation auf die neueste Version   |
|upgrade-k3s-control-cluster.yaml   |Aktualisiert eine bestehende K3S Installation auf die neueste Version auf Knoten, die unter die Kategorie control-cluster-nodes fallen   |
|upgrade-rancher.yaml   |Aktualisiert eine bestehende Rancher Installation   |

Es ist möglich, bestimmte Schritte zu überspringen. Dazu sind diese mit Tags versehen worden. Mögliche Tags sind:

|Tag   |Bedeutung   |
|---|---|
|k3s_setup_cleanup_nodes   |Bereinigt sämtliche Nodes. Es ist angeraten, diesen Schritt bei einer Neuinstallation durchzuführen. Erfordert Neustart der bereinigten Nodes.   |
|k3s_setup_disable_selinux   |Deaktiviert temporär SELinux, um Rancher-spezifische Pods starten zu können. Anschließend wird SELinux wieder aktiviert   |
|k3s_setup_install_master   |Installiert K3S auf den als Master-Nodes deklarierten Knoten   |
|k3s_setup_install_worker   |Installiert K3S auf den als Worker-Nodes deklarierten KnotenAktualisiert die Rancher-Installation des Control-Clusters   |
|k3s_setup_upgrade_cluster   |Aktualisiert die K3S Installation sämtlicher Knoten   |
|k3s_setup_upgrade_rancher   |Aktualisiert die Rancher-Installation des Control-Clusters  |

Ein entsprechender Ansible Befehl kann beispielsweise so aussehen:

*ansible-playbook -i inventories/kne/hosts plays/cluster-setup-with-k3s.yaml --ask-vault-pass --skip-tags=k3s_setup_cleanup_nodes*

Anstatt bestimmte tags zu überspringen, ist es auch möglich, nur bestimmte tags auszuführen. Dazu verwendet man das Argument --tags anstelle von --skip-tags. ein Besipiel:

*ansible-playbook -i inventories/kne/hosts plays/cluster-setup-with-k3s.yaml --ask-vault-pass --tags=k3s_setup_install_master,k3s_setup_install_worker*

# SSH-Authentifizierung mit Benutzername und Passwort

Wenn eine Authentifizierung mit dem SSH-Key auf den Zielknoten nicht möglich ist, ist alternativ auch eine Anmeldung mit Benutzername und Passwort möglich. Dafür wird in der ansible.cfg-Datei die Zeile `ansible_user = <user>` hinzugefügt, wobei `<user>` mit dem entsprechenden Benutzernamen ersetzt wird. Das Passwort kann beim Ausführen der Playbooks angegeben werden, indem die Option `--ask-pass` genutzt wird.

# Einbindung neuer Cluster in Rancher

Neue Cluster werden aktuell noch über die Rancher Oberfläche erstellt. Dafür werden folgende Schritte ausgeführt:
1. In der Ansicht "Global" wird die Schaltfläche "Add Cluster" betätigt und die Option "Other Cluster" wird ausgewählt.
1. Der Name des neuen Clusters wird angegeben.
1. Nun ist das neue Cluster erstellt. Um die K3S-Knoten einzubinden, wird der zweite Befehl aus der abschließenden Ansicht (`kubectl apply -f <yaml_file>`) auf den Masterknoten ausgeführt.

# Bekannte Probleme

1. Aktuell treffen die Playbooks die Annahme, das sämtliche benötigten Images bereits in Harbor enthalten sind. Es sollte ein Playbook zur entsprechenden Vorbereitung geben.
2. Aktuell sind die benötigten Installationsdateien Teil des Repositories. Diese sollten aber irgendwo abgelegt werden, wo sie durch Angabe einer Versionsnummer bezogen werden können (z.B. Webserver). So lässt sich eine Versionierung gut lösen.
