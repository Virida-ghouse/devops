import React, { useState, useEffect } from 'react';
import './GiteaIntegration.css';

const GiteaIntegration = () => {
  const [repoInfo, setRepoInfo] = useState(null);
  const [commits, setCommits] = useState([]);
  const [branches, setBranches] = useState([]);
  const [issues, setIssues] = useState([]);
  const [stats, setStats] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const API_BASE_URL = process.env.REACT_APP_GITEA_BRIDGE_URL || 'http://localhost:3001';

  // Récupérer les informations du dépôt
  const fetchRepoInfo = async () => {
    try {
      setLoading(true);
      const response = await fetch(`${API_BASE_URL}/api/gitea/repo-info`);
      const data = await response.json();
      if (data.success) {
        setRepoInfo(data.data);
      } else {
        setError(data.error);
      }
    } catch (err) {
      setError('Erreur lors de la récupération des informations du dépôt');
    } finally {
      setLoading(false);
    }
  };

  // Récupérer les commits récents
  const fetchCommits = async () => {
    try {
      setLoading(true);
      const response = await fetch(`${API_BASE_URL}/api/gitea/commits?limit=10`);
      const data = await response.json();
      if (data.success) {
        setCommits(data.data);
      } else {
        setError(data.error);
      }
    } catch (err) {
      setError('Erreur lors de la récupération des commits');
    } finally {
      setLoading(false);
    }
  };

  // Récupérer les branches
  const fetchBranches = async () => {
    try {
      setLoading(true);
      const response = await fetch(`${API_BASE_URL}/api/gitea/branches`);
      const data = await response.json();
      if (data.success) {
        setBranches(data.data);
      } else {
        setError(data.error);
      }
    } catch (err) {
      setError('Erreur lors de la récupération des branches');
    } finally {
      setLoading(false);
    }
  };

  // Récupérer les issues
  const fetchIssues = async () => {
    try {
      setLoading(true);
      const response = await fetch(`${API_BASE_URL}/api/gitea/issues?state=open`);
      const data = await response.json();
      if (data.success) {
        setIssues(data.data);
      } else {
        setError(data.error);
      }
    } catch (err) {
      setError('Erreur lors de la récupération des issues');
    } finally {
      setLoading(false);
    }
  };

  // Récupérer les statistiques
  const fetchStats = async () => {
    try {
      setLoading(true);
      const response = await fetch(`${API_BASE_URL}/api/gitea/stats`);
      const data = await response.json();
      if (data.success) {
        setStats(data.data);
      } else {
        setError(data.error);
      }
    } catch (err) {
      setError('Erreur lors de la récupération des statistiques');
    } finally {
      setLoading(false);
    }
  };

  // Synchroniser les données environnementales
  const syncEnvironmentalData = async (data) => {
    try {
      setLoading(true);
      const response = await fetch(`${API_BASE_URL}/api/gitea/sync-environmental-data`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          data: data,
          commitMessage: `Sync environmental data - ${new Date().toLocaleString()}`
        }),
      });
      const result = await response.json();
      if (result.success) {
        alert('Données environnementales synchronisées avec succès !');
      } else {
        setError(result.error);
      }
    } catch (err) {
      setError('Erreur lors de la synchronisation des données');
    } finally {
      setLoading(false);
    }
  };

  // Charger toutes les données au montage du composant
  useEffect(() => {
    fetchRepoInfo();
    fetchCommits();
    fetchBranches();
    fetchIssues();
    fetchStats();
  }, []);

  if (loading) {
    return (
      <div className="gitea-integration">
        <div className="loading">🔄 Chargement des données Gitea...</div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="gitea-integration">
        <div className="error">❌ {error}</div>
        <button onClick={() => {
          setError(null);
          fetchRepoInfo();
          fetchCommits();
          fetchBranches();
          fetchIssues();
          fetchStats();
        }}>🔄 Réessayer</button>
      </div>
    );
  }

  return (
    <div className="gitea-integration">
      <h2>🔗 Intégration Gitea - VIRIDA</h2>
      
      {/* Informations du dépôt */}
      {repoInfo && (
        <div className="repo-info">
          <h3>📊 Informations du dépôt</h3>
          <div className="info-grid">
            <div className="info-item">
              <span className="label">Nom:</span>
              <span className="value">{repoInfo.name}</span>
            </div>
            <div className="info-item">
              <span className="label">Description:</span>
              <span className="value">{repoInfo.description}</span>
            </div>
            <div className="info-item">
              <span className="label">⭐ Stars:</span>
              <span className="value">{repoInfo.stars}</span>
            </div>
            <div className="info-item">
              <span className="label">🍴 Forks:</span>
              <span className="value">{repoInfo.forks}</span>
            </div>
            <div className="info-item">
              <span className="label">📅 Dernière mise à jour:</span>
              <span className="value">{new Date(repoInfo.lastUpdated).toLocaleString()}</span>
            </div>
            <div className="info-item">
              <span className="label">💾 Taille:</span>
              <span className="value">{repoInfo.size} KB</span>
            </div>
          </div>
        </div>
      )}

      {/* Statistiques de développement */}
      {stats && (
        <div className="dev-stats">
          <h3>📈 Statistiques de développement (30 derniers jours)</h3>
          <div className="stats-grid">
            <div className="stat-item">
              <span className="stat-number">{stats.totalCommits}</span>
              <span className="stat-label">Commits</span>
            </div>
            <div className="stat-item">
              <span className="stat-number">{Object.keys(stats.authorStats).length}</span>
              <span className="stat-label">Contributeurs</span>
            </div>
            <div className="stat-item">
              <span className="stat-number">
                {Object.values(stats.authorStats).reduce((sum, author) => sum + author.additions, 0)}
              </span>
              <span className="stat-label">Lignes ajoutées</span>
            </div>
          </div>
          
          <div className="author-stats">
            <h4>👥 Contributions par auteur</h4>
            {Object.entries(stats.authorStats).map(([author, data]) => (
              <div key={author} className="author-item">
                <span className="author-name">{author}</span>
                <span className="author-commits">{data.commits} commits</span>
                <span className="author-changes">+{data.additions} -{data.deletions}</span>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Commits récents */}
      {commits.length > 0 && (
        <div className="recent-commits">
          <h3>🕒 Commits récents</h3>
          <div className="commits-list">
            {commits.map((commit) => (
              <div key={commit.id} className="commit-item">
                <div className="commit-message">{commit.message}</div>
                <div className="commit-meta">
                  <span className="commit-author">👤 {commit.author}</span>
                  <span className="commit-date">📅 {new Date(commit.date).toLocaleString()}</span>
                  {commit.stats && (
                    <span className="commit-stats">
                      +{commit.stats.additions} -{commit.stats.deletions}
                    </span>
                  )}
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Branches */}
      {branches.length > 0 && (
        <div className="branches">
          <h3>🌿 Branches</h3>
          <div className="branches-list">
            {branches.map((branch) => (
              <div key={branch.name} className="branch-item">
                <span className="branch-name">{branch.name}</span>
                <span className="branch-protected">{branch.protected ? '🔒' : '🔓'}</span>
                <span className="branch-commit">{branch.commit.substring(0, 7)}</span>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Issues ouvertes */}
      {issues.length > 0 && (
        <div className="issues">
          <h3>🎫 Issues ouvertes</h3>
          <div className="issues-list">
            {issues.map((issue) => (
              <div key={issue.id} className="issue-item">
                <div className="issue-title">{issue.title}</div>
                <div className="issue-meta">
                  <span className="issue-author">👤 {issue.author}</span>
                  <span className="issue-date">📅 {new Date(issue.createdAt).toLocaleString()}</span>
                  <span className="issue-type">{issue.isPullRequest ? '🔄 PR' : '🎫 Issue'}</span>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Bouton de synchronisation */}
      <div className="sync-section">
        <h3>🔄 Synchronisation des données environnementales</h3>
        <button 
          onClick={() => syncEnvironmentalData({
            timestamp: new Date().toISOString(),
            environmentalMetrics: {
              co2: Math.random() * 100,
              temperature: Math.random() * 30 + 15,
              humidity: Math.random() * 100,
              airQuality: Math.random() * 200
            },
            source: 'virida_ihm_dashboard'
          })}
          className="sync-button"
        >
          📊 Synchroniser avec Git
        </button>
      </div>
    </div>
  );
};

export default GiteaIntegration;
