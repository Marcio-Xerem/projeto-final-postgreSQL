const express = require('express');
const { Pool } = require('pg');
const bodyParser = require('body-parser');
const path = require('path');

const app = express();
const port = 3000;

// Configuração do banco de dados
const pool = new Pool({
    user: 'postgres',
    host: 'localhost',
    database: 'bd_carnaval',
    password: 'postgres',
    port: 5432,
});

// Middleware
app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());
app.use(express.static('public'));

// Rota: Página inicial
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// Rota: Página de cadastro de notas
app.get('/cadastro', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'cadastro_notas.html'));
});

// Rota: Página de relatórios
app.get('/relatorios', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'relatorios.html'));
});

// Rota API: Listar todas as escolas
app.get('/api/escolas', async (req, res) => {
    try {
        const query = 'SELECT id_escola, nome_escola FROM escolas ORDER BY nome_escola';
        const result = await pool.query(query);
        res.json(result.rows);
    } catch (error) {
        console.error('Erro ao buscar escolas:', error);
        res.status(500).json({ erro: 'Erro ao buscar escolas' });
    }
});

// Rota API: Listar todos os jurados
app.get('/api/jurados', async (req, res) => {
    try {
        const query = 'SELECT id_jurado, nome_jurado FROM jurados ORDER BY nome_jurado';
        const result = await pool.query(query);
        res.json(result.rows);
    } catch (error) {
        console.error('Erro ao buscar jurados:', error);
        res.status(500).json({ erro: 'Erro ao buscar jurados' });
    }
});

// Rota API: Listar todos os quesitos
app.get('/api/quesitos', async (req, res) => {
    try {
        const query = 'SELECT id_quesito, nome_quesito FROM quesitos ORDER BY id_quesito';
        const result = await pool.query(query);
        res.json(result.rows);
    } catch (error) {
        console.error('Erro ao buscar quesitos:', error);
        res.status(500).json({ erro: 'Erro ao buscar quesitos' });
    }
});

// Rota API: Cadastrar nota
app.post('/api/notas', async (req, res) => {
    const { id_escola, id_jurado, id_quesito, nota } = req.body;

    if (!id_escola || !id_jurado || !id_quesito || !nota) {
        return res.status(400).json({ erro: 'Todos os campos são obrigatórios' });
    }

    if (nota < 9.0 || nota > 10.0) {
        return res.status(400).json({ erro: 'Nota deve estar entre 9.0 e 10.0' });
    }

    try {
        const query = `
      INSERT INTO notas (fk_id_escola, fk_id_jurado, fk_id_quesito, nota, data_lancamento)
      VALUES ($1, $2, $3, $4, NOW())
      ON CONFLICT (fk_id_escola, fk_id_jurado, fk_id_quesito) 
      DO UPDATE SET nota = $4, data_lancamento = NOW()
    `;
        await pool.query(query, [id_escola, id_jurado, id_quesito, nota]);
        res.json({ sucesso: 'Nota cadastrada com sucesso!' });
    } catch (error) {
        console.error('Erro ao cadastrar nota:', error);
        res.status(500).json({ erro: 'Erro ao cadastrar nota' });
    }
});

// Rota API: Visualizar notas individuais
app.get('/api/relatorio/notas-individuais', async (req, res) => {
    try {
        const query = 'SELECT * FROM vw_notas_individuais ORDER BY nome_escola, nome_quesito, nome_jurado';
        const result = await pool.query(query);
        res.json(result.rows);
    } catch (error) {
        console.error('Erro ao buscar notas individuais:', error);
        res.status(500).json({ erro: 'Erro ao buscar notas individuais' });
    }
});

// Rota API: Visualizar nota final por quesito
app.get('/api/relatorio/nota-final-quesito', async (req, res) => {
    try {
        const query = 'SELECT * FROM vw_nota_final_quesito ORDER BY nome_escola, nome_quesito';
        const result = await pool.query(query);
        res.json(result.rows);
    } catch (error) {
        console.error('Erro ao buscar nota final:', error);
        res.status(500).json({ erro: 'Erro ao buscar nota final' });
    }
});

// Rota API: Visualizar pontuação total
app.get('/api/relatorio/pontuacao-total', async (req, res) => {
    try {
        const query = 'SELECT * FROM vw_pontuacao_total ORDER BY pontuacao_total DESC';
        const result = await pool.query(query);
        res.json(result.rows);
    } catch (error) {
        console.error('Erro ao buscar pontuação total:', error);
        res.status(500).json({ erro: 'Erro ao buscar pontuação total' });
    }
});

// Rota API: Visualizar escola vencedora
app.get('/api/relatorio/escola-vencedora', async (req, res) => {
    try {
        const query = 'SELECT * FROM vw_escola_vencedora';
        const result = await pool.query(query);
        res.json(result.rows[0] || {});
    } catch (error) {
        console.error('Erro ao buscar escola vencedora:', error);
        res.status(500).json({ erro: 'Erro ao buscar escola vencedora' });
    }
});

// Rota API: Verificar se um jurado já cadastrou notas para uma escola
app.get('/api/verificar-nota', async (req, res) => {
    const { id_jurado, id_escola } = req.query;

    if (!id_jurado || !id_escola) {
        return res.status(400).json({ existe: false });
    }

    try {
        const query = `
      SELECT COUNT(*) as total
      FROM notas
      WHERE fk_id_jurado = $1 AND fk_id_escola = $2
    `;
        const result = await pool.query(query, [id_jurado, id_escola]);
        const existe = result.rows[0].total > 0;

        res.json({ existe });
    } catch (error) {
        console.error('Erro ao verificar nota:', error);
        res.status(500).json({ existe: false });
    }
});

// Rota API: Listar todos os jurados com foto (BYTEA -> Base64)
app.get('/api/jurados-com-foto', async (req, res) => {
    try {
        const query = `
            SELECT 
                id_jurado, 
                nome_jurado, 
                CASE 
                    WHEN foto IS NOT NULL THEN encode(foto, 'base64') 
                    ELSE NULL 
                END AS foto_base64
            FROM jurados 
            ORDER BY nome_jurado
        `;
        const result = await pool.query(query);
        res.json(result.rows);
    } catch (error) {
        console.error('❌ Erro ao buscar jurados com foto:', error);
        res.status(500).json({ erro: 'Erro ao buscar jurados com foto' });
    }
});

// Iniciar servidor
app.listen(port, () => {
    console.log(`Servidor rodando em http://localhost:${port}`);
});