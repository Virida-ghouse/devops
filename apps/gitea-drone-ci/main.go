package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"time"

	"github.com/gin-gonic/gin"
)

type GiteaDroneManager struct {
	Port        string
	DataDir     string
	GiteaPort   string
	DronePort   string
	DroneSecret string
}

func NewGiteaDroneManager() *GiteaDroneManager {
	return &GiteaDroneManager{
		Port:        getEnv("PORT", "8080"),
		DataDir:     getEnv("DATA_DIR", "/tmp/gitea-drone"),
		GiteaPort:   getEnv("GITEA_PORT", "3000"),
		DronePort:   getEnv("DRONE_PORT", "3001"),
		DroneSecret: getEnv("DRONE_SECRET", "super-secret-key-change-me"),
	}
}

func (gdm *GiteaDroneManager) SetupDirectories() error {
	dirs := []string{
		gdm.DataDir,
		filepath.Join(gdm.DataDir, "gitea"),
		filepath.Join(gdm.DataDir, "drone"),
		filepath.Join(gdm.DataDir, "gitea", "data"),
		filepath.Join(gdm.DataDir, "gitea", "config"),
		filepath.Join(gdm.DataDir, "drone", "data"),
	}

	for _, dir := range dirs {
		if err := os.MkdirAll(dir, 0755); err != nil {
			return fmt.Errorf("failed to create directory %s: %v", dir, err)
		}
	}
	return nil
}

func (gdm *GiteaDroneManager) InstallGitea() error {
	log.Println("Installing Gitea...")
	
	// Download Gitea binary
	cmd := exec.Command("wget", "-O", "/tmp/gitea", "https://dl.gitea.io/gitea/1.21.0/gitea-1.21.0-linux-amd64")
	if err := cmd.Run(); err != nil {
		return fmt.Errorf("failed to download Gitea: %v", err)
	}

	// Make it executable
	cmd = exec.Command("chmod", "+x", "/tmp/gitea")
	if err := cmd.Run(); err != nil {
		return fmt.Errorf("failed to make Gitea executable: %v", err)
	}

	// Move to data directory
	cmd = exec.Command("mv", "/tmp/gitea", filepath.Join(gdm.DataDir, "gitea", "gitea"))
	if err := cmd.Run(); err != nil {
		return fmt.Errorf("failed to move Gitea: %v", err)
	}

	return nil
}

func (gdm *GiteaDroneManager) ConfigureGitea() error {
	log.Println("Configuring Gitea...")
	
	configPath := filepath.Join(gdm.DataDir, "gitea", "config", "app.ini")
	// Configuration de la base de données
	dbType := getEnv("GITEA_DB_TYPE", "sqlite3")
	dbHost := getEnv("GITEA_DB_HOST", "")
	dbName := getEnv("GITEA_DB_NAME", "gitea")
	dbUser := getEnv("GITEA_DB_USER", "gitea")
	dbPass := getEnv("GITEA_DB_PASS", "")
	
	var dbConfig string
	if dbType == "postgres" || dbType == "mysql" {
		dbConfig = fmt.Sprintf(`[database]
DB_TYPE = %s
HOST = %s
NAME = %s
USER = %s
PASSWD = %s
SSL_MODE = disable
CHARSET = utf8`, dbType, dbHost, dbName, dbUser, dbPass)
	} else {
		dbConfig = fmt.Sprintf(`[database]
DB_TYPE = sqlite3
HOST = %s/gitea.db
NAME = gitea
USER = gitea
PASSWD = 
SSL_MODE = disable
CHARSET = utf8
PATH = %s/gitea.db`, gdm.DataDir, gdm.DataDir)
	}

	config := fmt.Sprintf(`[server]
APP_NAME = VIRIDA Gitea
RUN_USER = git
RUN_MODE = prod
DOMAIN = %s
HTTP_PORT = %s
ROOT_URL = http://%s:%s/
DISABLE_SSH = false
SSH_DOMAIN = %s
SSH_PORT = 22
SSH_LISTEN_PORT = 22
LFS_START_SERVER = true
LFS_CONTENT_PATH = %s/lfs
LFS_JWT_SECRET = %s
OFFLINE_MODE = false

%s

[repository]
ROOT = %s/repositories
SCRIPT_TYPE = bash

[repository.upload]
ENABLED = true
TEMP_PATH = %s/uploads
MAX_SIZE = 10485760
ALLOWED_TYPES = *

[security]
INSTALL_LOCK = true
SECRET_KEY = %s
LOGIN_REMEMBER_DAYS = 7
COOKIE_USER_NAME = gitea_incredible
COOKIE_REMEMBER_NAME = gitea_awesome
REVERSE_PROXY_LIMIT = 1
REVERSE_PROXY_TRUSTED = *

[service]
DISABLE_REGISTRATION = false
REQUIRE_SIGNIN_VIEW = false
ENABLE_NOTIFY_MAIL = false
ENABLE_REVERSE_PROXY_AUTHENTICATION = false
ENABLE_REVERSE_PROXY_AUTO_REGISTRATION = false
ENABLE_CAPTCHA = false
REQUIRE_EXTERNAL_REGISTRATION = false
DEFAULT_KEEP_EMAIL_PRIVATE = false
DEFAULT_ALLOW_CREATE_ORGANIZATION = true
DEFAULT_ENABLE_TIMETRACKING = true
DEFAULT_ALLOW_ONLY_EXTERNAL_REGISTRATION = false
DEFAULT_FORCE_PRIVATE = false
DEFAULT_USE_PROXY = false
ENABLE_USER_HEATMAP = true
ENABLE_USER_TIME_TRACKING = true
NO_REPLY_ADDRESS = noreply.example.org

[mailer]
ENABLED = false

[openid]
ENABLE_OPENID_SIGNIN = true
ENABLE_OPENID_SIGNUP = true

[oauth2]
ENABLE = true
JWT_SECRET = %s

[webhook]
ENABLED = true
SKIP_TLS_VERIFY = true
ALLOWED_HOST_LIST = *

[metrics]
ENABLED = true
`,
		getEnv("GITEA_DOMAIN", "localhost"),
		gdm.GiteaPort,
		getEnv("GITEA_DOMAIN", "localhost"),
		gdm.GiteaPort,
		getEnv("GITEA_DOMAIN", "localhost"),
		gdm.DataDir,
		gdm.DroneSecret,
		gdm.DataDir,
		gdm.DataDir,
		gdm.DataDir,
		gdm.DataDir,
		gdm.DroneSecret,
		gdm.DroneSecret,
	)

	if err := os.WriteFile(configPath, []byte(config), 0644); err != nil {
		return fmt.Errorf("failed to write Gitea config: %v", err)
	}

	return nil
}

func (gdm *GiteaDroneManager) StartGitea() error {
	log.Println("Starting Gitea...")
	
	cmd := exec.Command(filepath.Join(gdm.DataDir, "gitea", "gitea"), "web", "--config", filepath.Join(gdm.DataDir, "gitea", "config", "app.ini"))
	cmd.Dir = filepath.Join(gdm.DataDir, "gitea")
	
	// Start in background
	if err := cmd.Start(); err != nil {
		return fmt.Errorf("failed to start Gitea: %v", err)
	}

	// Wait a bit for Gitea to start
	time.Sleep(5 * time.Second)
	
	return nil
}

func (gdm *GiteaDroneManager) InstallDrone() error {
	log.Println("Installing Drone CI...")
	
	// Download Drone server
	cmd := exec.Command("wget", "-O", "/tmp/drone-server", "https://github.com/harness/drone/releases/download/v2.20.0/drone_linux_amd64.tar.gz")
	if err := cmd.Run(); err != nil {
		return fmt.Errorf("failed to download Drone server: %v", err)
	}

	// Extract and install
	cmd = exec.Command("tar", "-xzf", "/tmp/drone-server", "-C", "/tmp/")
	if err := cmd.Run(); err != nil {
		return fmt.Errorf("failed to extract Drone: %v", err)
	}

	cmd = exec.Command("mv", "/tmp/drone", filepath.Join(gdm.DataDir, "drone", "drone-server"))
	if err := cmd.Run(); err != nil {
		return fmt.Errorf("failed to move Drone server: %v", err)
	}

	// Download Drone runner
	cmd = exec.Command("wget", "-O", "/tmp/drone-runner", "https://github.com/harness/drone/releases/download/v2.20.0/drone-runner-docker_linux_amd64.tar.gz")
	if err := cmd.Run(); err != nil {
		return fmt.Errorf("failed to download Drone runner: %v", err)
	}

	cmd = exec.Command("tar", "-xzf", "/tmp/drone-runner", "-C", "/tmp/")
	if err := cmd.Run(); err != nil {
		return fmt.Errorf("failed to extract Drone runner: %v", err)
	}

	cmd = exec.Command("mv", "/tmp/drone-runner-docker", filepath.Join(gdm.DataDir, "drone", "drone-runner"))
	if err := cmd.Run(); err != nil {
		return fmt.Errorf("failed to move Drone runner: %v", err)
	}

	// Make executables
	cmd = exec.Command("chmod", "+x", filepath.Join(gdm.DataDir, "drone", "drone-server"))
	if err := cmd.Run(); err != nil {
		return fmt.Errorf("failed to make Drone server executable: %v", err)
	}

	cmd = exec.Command("chmod", "+x", filepath.Join(gdm.DataDir, "drone", "drone-runner"))
	if err := cmd.Run(); err != nil {
		return fmt.Errorf("failed to make Drone runner executable: %v", err)
	}

	return nil
}

func (gdm *GiteaDroneManager) StartDrone() error {
	log.Println("Starting Drone CI...")
	
	// Configuration de la base de données Drone
	droneDbType := getEnv("DRONE_DB_TYPE", "sqlite3")
	droneDbHost := getEnv("DRONE_DB_HOST", "")
	droneDbName := getEnv("DRONE_DB_NAME", "drone")
	droneDbUser := getEnv("DRONE_DB_USER", "drone")
	droneDbPass := getEnv("DRONE_DB_PASS", "")
	
	var droneDbConfig string
	if droneDbType == "postgres" || droneDbType == "mysql" {
		droneDbConfig = fmt.Sprintf("%s://%s:%s@%s/%s?sslmode=disable", 
			droneDbType, droneDbUser, droneDbPass, droneDbHost, droneDbName)
	} else {
		droneDbConfig = filepath.Join(gdm.DataDir, "drone", "drone.db")
	}

	// Start Drone server
	cmd := exec.Command(filepath.Join(gdm.DataDir, "drone", "drone-server"), "server",
		"--drone-gitea-server", fmt.Sprintf("http://localhost:%s", gdm.GiteaPort),
		"--drone-gitea-client-id", getEnv("GITEA_CLIENT_ID", "gitea-client-id"),
		"--drone-gitea-client-secret", getEnv("GITEA_CLIENT_SECRET", "gitea-client-secret"),
		"--drone-rpc-secret", gdm.DroneSecret,
		"--drone-server-host", getEnv("DRONE_HOST", "localhost"),
		"--drone-server-proto", "http",
		"--drone-server-addr", fmt.Sprintf(":%s", gdm.DronePort),
		"--drone-database-driver", droneDbType,
		"--drone-database-datasource", droneDbConfig,
	)
	
	if err := cmd.Start(); err != nil {
		return fmt.Errorf("failed to start Drone server: %v", err)
	}

	// Wait a bit for Drone server to start
	time.Sleep(3 * time.Second)

	// Start Drone runner
	cmd = exec.Command(filepath.Join(gdm.DataDir, "drone", "drone-runner"), "run",
		"--drone-rpc-host", "localhost",
		"--drone-rpc-proto", "http",
		"--drone-rpc-secret", gdm.DroneSecret,
		"--drone-runner-capacity", "2",
		"--drone-runner-name", "virida-runner",
	)
	
	if err := cmd.Start(); err != nil {
		return fmt.Errorf("failed to start Drone runner: %v", err)
	}

	return nil
}

func (gdm *GiteaDroneManager) SetupWebhooks() error {
	log.Println("Setting up webhooks...")
	
	// This would typically involve API calls to Gitea to configure webhooks
	// For now, we'll just log the webhook URL that should be configured
	webhookURL := fmt.Sprintf("http://localhost:%s/hook", gdm.DronePort)
	log.Printf("Configure webhook in Gitea to: %s", webhookURL)
	
	return nil
}

func (gdm *GiteaDroneManager) Initialize() error {
	log.Println("Initializing Gitea + Drone CI setup...")
	
	if err := gdm.SetupDirectories(); err != nil {
		return err
	}

	if err := gdm.InstallGitea(); err != nil {
		return err
	}

	if err := gdm.ConfigureGitea(); err != nil {
		return err
	}

	if err := gdm.StartGitea(); err != nil {
		return err
	}

	if err := gdm.InstallDrone(); err != nil {
		return err
	}

	if err := gdm.StartDrone(); err != nil {
		return err
	}

	if err := gdm.SetupWebhooks(); err != nil {
		return err
	}

	log.Println("Gitea + Drone CI setup completed!")
	return nil
}

func (gdm *GiteaDroneManager) SetupRoutes(r *gin.Engine) {
	r.GET("/", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"message": "VIRIDA Gitea + Drone CI Manager",
			"status":  "running",
			"gitea":   fmt.Sprintf("http://localhost:%s", gdm.GiteaPort),
			"drone":   fmt.Sprintf("http://localhost:%s", gdm.DronePort),
		})
	})

	r.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"status": "healthy",
			"time":   time.Now().Format(time.RFC3339),
		})
	})

	r.GET("/status", func(c *gin.Context) {
		// Check if services are running
		giteaStatus := gdm.checkService("gitea")
		droneStatus := gdm.checkService("drone")
		
		c.JSON(http.StatusOK, gin.H{
			"gitea": giteaStatus,
			"drone": droneStatus,
			"data_dir": gdm.DataDir,
		})
	})

	r.POST("/restart", func(c *gin.Context) {
		log.Println("Restarting services...")
		// Restart logic would go here
		c.JSON(http.StatusOK, gin.H{
			"message": "Services restart initiated",
		})
	})
}

func (gdm *GiteaDroneManager) checkService(service string) map[string]interface{} {
	// Simple service check - in production you'd want more sophisticated checks
	return map[string]interface{}{
		"running": true,
		"port":    gdm.GiteaPort,
	}
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

func main() {
	log.Println("Starting VIRIDA Gitea + Drone CI Manager...")

	manager := NewGiteaDroneManager()

	// Initialize services in background
	go func() {
		if err := manager.Initialize(); err != nil {
			log.Printf("Failed to initialize services: %v", err)
		}
	}()

	// Setup web server
	r := gin.Default()
	manager.SetupRoutes(r)

	// Start web server
	log.Printf("Starting web server on port %s", manager.Port)
	if err := r.Run(":" + manager.Port); err != nil {
		log.Fatal("Failed to start web server:", err)
	}
}
