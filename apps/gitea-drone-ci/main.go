package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"time"

	"github.com/gin-gonic/gin"
)

func main() {
	log.Println("Starting VIRIDA Gitea + Drone CI Manager...")

	// Configuration
	port := getEnv("PORT", "8080")
	dataDir := getEnv("DATA_DIR", "/tmp/gitea-drone")
	giteaPort := getEnv("GITEA_PORT", "3000")
	dronePort := getEnv("DRONE_PORT", "3001")

	log.Printf("Configuration:")
	log.Printf("- Port: %s", port)
	log.Printf("- Data Dir: %s", dataDir)
	log.Printf("- Gitea Port: %s", giteaPort)
	log.Printf("- Drone Port: %s", dronePort)

	// Créer les répertoires
	if err := os.MkdirAll(dataDir, 0755); err != nil {
		log.Fatalf("Failed to create data directory: %v", err)
	}

	// Installer et configurer Gitea
	go func() {
		if err := installAndConfigureGitea(dataDir, giteaPort); err != nil {
			log.Printf("Failed to setup Gitea: %v", err)
		}
	}()

	// Installer et configurer Drone
	go func() {
		time.Sleep(10 * time.Second) // Attendre que Gitea soit prêt
		if err := installAndConfigureDrone(dataDir, dronePort, giteaPort); err != nil {
			log.Printf("Failed to setup Drone: %v", err)
		}
	}()

	// Setup web server
	r := gin.Default()
	
	r.GET("/", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"message": "VIRIDA Gitea + Drone CI Manager",
			"status":  "running",
			"gitea":   fmt.Sprintf("http://localhost:%s", giteaPort),
			"drone":   fmt.Sprintf("http://localhost:%s", dronePort),
		})
	})

	r.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"status": "healthy",
			"time":   time.Now().Format(time.RFC3339),
		})
	})

	r.GET("/status", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"gitea_running": checkService("gitea", giteaPort),
			"drone_running": checkService("drone", dronePort),
			"data_dir":      dataDir,
		})
	})

	// Start web server
	log.Printf("Starting web server on port %s", port)
	if err := r.Run(":" + port); err != nil {
		log.Fatal("Failed to start web server:", err)
	}
}

func installAndConfigureGitea(dataDir, port string) error {
	log.Println("Installing Gitea...")
	
	giteaDir := filepath.Join(dataDir, "gitea")
	if err := os.MkdirAll(giteaDir, 0755); err != nil {
		return err
	}

	// Télécharger Gitea
	cmd := exec.Command("wget", "-O", "/tmp/gitea", "https://dl.gitea.io/gitea/1.21.0/gitea-1.21.0-linux-amd64")
	if err := cmd.Run(); err != nil {
		return fmt.Errorf("failed to download Gitea: %v", err)
	}

	// Rendre exécutable et déplacer
	exec.Command("chmod", "+x", "/tmp/gitea").Run()
	exec.Command("mv", "/tmp/gitea", filepath.Join(giteaDir, "gitea")).Run()

	// Configuration Gitea
	configDir := filepath.Join(giteaDir, "config")
	os.MkdirAll(configDir, 0755)

	config := fmt.Sprintf(`[server]
APP_NAME = VIRIDA Gitea
RUN_USER = git
RUN_MODE = prod
DOMAIN = localhost
HTTP_PORT = %s
ROOT_URL = http://localhost:%s/
DISABLE_SSH = true

[database]
DB_TYPE = sqlite3
PATH = %s/gitea.db

[repository]
ROOT = %s/repositories

[security]
INSTALL_LOCK = true
SECRET_KEY = %s

[service]
DISABLE_REGISTRATION = false
`, port, port, giteaDir, giteaDir, getEnv("DRONE_SECRET", "secret-key"))

	configPath := filepath.Join(configDir, "app.ini")
	if err := os.WriteFile(configPath, []byte(config), 0644); err != nil {
		return fmt.Errorf("failed to write Gitea config: %v", err)
	}

	// Démarrer Gitea
	log.Println("Starting Gitea...")
	cmd = exec.Command(filepath.Join(giteaDir, "gitea"), "web", "--config", configPath)
	cmd.Dir = giteaDir
	return cmd.Start()
}

func installAndConfigureDrone(dataDir, dronePort, giteaPort string) error {
	log.Println("Installing Drone CI...")
	
	droneDir := filepath.Join(dataDir, "drone")
	if err := os.MkdirAll(droneDir, 0755); err != nil {
		return err
	}

	// Télécharger Drone server
	cmd := exec.Command("wget", "-O", "/tmp/drone-server.tar.gz", "https://github.com/harness/drone/releases/download/v2.20.0/drone_linux_amd64.tar.gz")
	if err := cmd.Run(); err != nil {
		return fmt.Errorf("failed to download Drone server: %v", err)
	}

	// Extraire et installer
	exec.Command("tar", "-xzf", "/tmp/drone-server.tar.gz", "-C", "/tmp/").Run()
	exec.Command("mv", "/tmp/drone", filepath.Join(droneDir, "drone-server")).Run()
	exec.Command("chmod", "+x", filepath.Join(droneDir, "drone-server")).Run()

	// Démarrer Drone server
	log.Println("Starting Drone CI...")
	cmd = exec.Command(filepath.Join(droneDir, "drone-server"), "server",
		"--drone-gitea-server", fmt.Sprintf("http://localhost:%s", giteaPort),
		"--drone-gitea-client-id", getEnv("GITEA_CLIENT_ID", "gitea-client-id"),
		"--drone-gitea-client-secret", getEnv("GITEA_CLIENT_SECRET", "gitea-client-secret"),
		"--drone-rpc-secret", getEnv("DRONE_SECRET", "secret-key"),
		"--drone-server-host", "localhost",
		"--drone-server-proto", "http",
		"--drone-server-addr", ":"+dronePort,
		"--drone-database-driver", "sqlite3",
		"--drone-database-datasource", filepath.Join(droneDir, "drone.db"),
	)
	
	return cmd.Start()
}

func checkService(service, port string) bool {
	// Simple check - en production vous voudriez une vérification plus robuste
	return true
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}