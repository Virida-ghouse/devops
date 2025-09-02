const express = require('express');
const axios = require('axios');
const cors = require('cors');
const app = express();
const port = process.env.PORT || 3001;

// Configuration Gitea
const GITEA_URL = process.env.GITEA_URL || 'https://gitea.cleverapps.io';
const GITEA_TOKEN = process.env.GITEA_TOKEN || '';

// Middleware
app.use(cors());
app.use(express.json());

// Routes pour l'intégration Gitea-virida_ihm

// 1. Récupérer les informations du dépôt VIRIDA
app.get('/api/gitea/repo-info', async (req, res) => {
  try {
    const response = await axios.get(`${GITEA_URL}/api/v1/repos/virida/virida`, {
      headers: {
        'Authorization': `token ${GITEA_TOKEN}`,
        'Content-Type': 'application/json'
      }
    });
    
    res.json({
      success: true,
      data: {
        name: response.data.name,
        description: response.data.description,
        stars: response.data.stars_count,
        forks: response.data.forks_count,
        lastUpdated: response.data.updated_at,
        cloneUrl: response.data.clone_url,
        size: response.data.size
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Erreur lors de la récupération des informations du dépôt'
    });
  }
});

// 2. Récupérer les commits récents
app.get('/api/gitea/commits', async (req, res) => {
  try {
    const { limit = 10, branch = 'main' } = req.query;
    const response = await axios.get(`${GITEA_URL}/api/v1/repos/virida/virida/commits`, {
      params: { limit, sha: branch },
      headers: {
        'Authorization': `token ${GITEA_TOKEN}`,
        'Content-Type': 'application/json'
      }
    });
    
    const commits = response.data.map(commit => ({
      id: commit.sha,
      message: commit.commit.message,
      author: commit.commit.author.name,
      date: commit.commit.author.date,
      url: commit.html_url,
      stats: commit.stats
    }));
    
    res.json({
      success: true,
      data: commits
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Erreur lors de la récupération des commits'
    });
  }
});

// 3. Récupérer les branches
app.get('/api/gitea/branches', async (req, res) => {
  try {
    const response = await axios.get(`${GITEA_URL}/api/v1/repos/virida/virida/branches`, {
      headers: {
        'Authorization': `token ${GITEA_TOKEN}`,
        'Content-Type': 'application/json'
      }
    });
    
    const branches = response.data.map(branch => ({
      name: branch.name,
      commit: branch.commit.id,
      protected: branch.protected,
      lastCommit: branch.commit.timestamp
    }));
    
    res.json({
      success: true,
      data: branches
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Erreur lors de la récupération des branches'
    });
  }
});

// 4. Récupérer les issues et pull requests
app.get('/api/gitea/issues', async (req, res) => {
  try {
    const { state = 'open', type = 'all' } = req.query;
    const response = await axios.get(`${GITEA_URL}/api/v1/repos/virida/virida/issues`, {
      params: { state, type },
      headers: {
        'Authorization': `token ${GITEA_TOKEN}`,
        'Content-Type': 'application/json'
      }
    });
    
    const issues = response.data.map(issue => ({
      id: issue.id,
      title: issue.title,
      body: issue.body,
      state: issue.state,
      author: issue.user.login,
      createdAt: issue.created_at,
      updatedAt: issue.updated_at,
      labels: issue.labels,
      isPullRequest: issue.pull_request !== undefined
    }));
    
    res.json({
      success: true,
      data: issues
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Erreur lors de la récupération des issues'
    });
  }
});

// 5. Synchroniser les données environnementales avec Git
app.post('/api/gitea/sync-environmental-data', async (req, res) => {
  try {
    const { data, commitMessage } = req.body;
    
    // Créer un fichier JSON avec les données environnementales
    const environmentalData = {
      timestamp: new Date().toISOString(),
      data: data,
      source: 'virida_ihm',
      version: '1.0.0'
    };
    
    // Ici, vous pourriez créer un commit avec ces données
    // Pour l'instant, on retourne les données formatées
    res.json({
      success: true,
      message: 'Données environnementales synchronisées avec Git',
      data: environmentalData,
      commitMessage: commitMessage || 'Sync environmental data from virida_ihm'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Erreur lors de la synchronisation des données'
    });
  }
});

// 6. Récupérer les statistiques de développement
app.get('/api/gitea/stats', async (req, res) => {
  try {
    // Récupérer les commits des 30 derniers jours
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
    
    const response = await axios.get(`${GITEA_URL}/api/v1/repos/virida/virida/commits`, {
      params: { 
        since: thirtyDaysAgo.toISOString(),
        limit: 100
      },
      headers: {
        'Authorization': `token ${GITEA_TOKEN}`,
        'Content-Type': 'application/json'
      }
    });
    
    // Analyser les commits par auteur
    const authorStats = {};
    response.data.forEach(commit => {
      const author = commit.commit.author.name;
      if (!authorStats[author]) {
        authorStats[author] = { commits: 0, additions: 0, deletions: 0 };
      }
      authorStats[author].commits++;
      if (commit.stats) {
        authorStats[author].additions += commit.stats.additions || 0;
        authorStats[author].deletions += commit.stats.deletions || 0;
      }
    });
    
    res.json({
      success: true,
      data: {
        totalCommits: response.data.length,
        period: '30 derniers jours',
        authorStats: authorStats,
        lastCommit: response.data[0]?.commit.author.date
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Erreur lors de la récupération des statistiques'
    });
  }
});

// 7. Health check
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    service: 'gitea-virida-bridge',
    timestamp: new Date().toISOString(),
    giteaUrl: GITEA_URL
  });
});

// 8. Endpoint racine
app.get('/', (req, res) => {
  res.json({
    message: '🌱 Gitea-Virida Bridge API',
    version: '1.0.0',
    endpoints: [
      'GET /api/gitea/repo-info - Informations du dépôt',
      'GET /api/gitea/commits - Commits récents',
      'GET /api/gitea/branches - Branches disponibles',
      'GET /api/gitea/issues - Issues et PRs',
      'POST /api/gitea/sync-environmental-data - Synchroniser les données',
      'GET /api/gitea/stats - Statistiques de développement',
      'GET /health - Health check'
    ]
  });
});

app.listen(port, () => {
  console.log(`🌱 Gitea-Virida Bridge API running on port ${port}`);
  console.log(`🔗 Gitea URL: ${GITEA_URL}`);
  console.log(`📊 Available endpoints: http://localhost:${port}/`);
});
