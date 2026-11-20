const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = process.env.PORT || 3000;
const DATA_FILE = path.join(__dirname, 'data.json');

function loadData() {
  try {
    const raw = fs.readFileSync(DATA_FILE, 'utf-8');
    return JSON.parse(raw);
  } catch (e) {
    return { responsables: [], bienes: [], entregas: [] };
  }
}

function saveData(data) {
  try {
    fs.writeFileSync(DATA_FILE, JSON.stringify(data, null, 2), 'utf-8');
  } catch (e) {
    console.error('Error guardando data.json:', e);
  }
}

let db = loadData();

function setCors(res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
}

function parseBody(req) {
  return new Promise((resolve, reject) => {
    let body = '';
    req.on('data', chunk => body += chunk);
    req.on('end', () => {
      try {
        resolve(body ? JSON.parse(body) : {});
      } catch (err) {
        reject(err);
      }
    });
    req.on('error', reject);
  });
}

const server = http.createServer(async (req, res) => {
  setCors(res);
  if (req.method === 'OPTIONS') {
    res.writeHead(204);
    res.end();
    return;
  }

  const parsedUrl = new URL(req.url, `http://${req.headers.host || 'localhost'}`);
  const pathname = parsedUrl.pathname;
  res.setHeader('Content-Type', 'application/json; charset=utf-8');

  try {
    // Endpoints BIENES
    if (pathname === '/api/bienes' && req.method === 'GET') {
      res.writeHead(200);
      res.end(JSON.stringify(db.bienes));
      return;
    }

    if (pathname === '/api/bienes' && req.method === 'POST') {
      const body = await parseBody(req);
      const newId = db.bienes.length > 0 ? Math.max(...db.bienes.map(b => b.id || 0)) + 1 : 1;
      const nuevoBien = {
        id: newId,
        codigoInstitucional: body.codigoInstitucional,
        nombre: body.nombre,
        descripcion: body.descripcion || '',
        cantidadTotal: parseInt(body.cantidadTotal) || 1,
        cantidadDisponible: parseInt(body.cantidadDisponible !== undefined ? body.cantidadDisponible : body.cantidadTotal) || 1,
        estado: body.estado || 'Disponible'
      };
      db.bienes.push(nuevoBien);
      saveData(db);
      res.writeHead(201);
      res.end(JSON.stringify(nuevoBien));
      return;
    }

    const bienMatch = pathname.match(/^\/api\/bienes\/(\d+)$/);
    if (bienMatch && req.method === 'PUT') {
      const id = parseInt(bienMatch[1]);
      const body = await parseBody(req);
      const index = db.bienes.findIndex(b => b.id === id);
      if (index === -1) {
        res.writeHead(404);
        res.end(JSON.stringify({ error: 'Bien no encontrado' }));
        return;
      }
      db.bienes[index] = { ...db.bienes[index], ...body, id };
      saveData(db);
      res.writeHead(200);
      res.end(JSON.stringify(db.bienes[index]));
      return;
    }

    if (bienMatch && req.method === 'DELETE') {
      const id = parseInt(bienMatch[1]);
      db.bienes = db.bienes.filter(b => b.id !== id);
      saveData(db);
      res.writeHead(200);
      res.end(JSON.stringify({ success: true }));
      return;
    }

    // Endpoints RESPONSABLES
    if (pathname === '/api/responsables' && req.method === 'GET') {
      res.writeHead(200);
      res.end(JSON.stringify(db.responsables));
      return;
    }

    if (pathname === '/api/responsables' && req.method === 'POST') {
      const body = await parseBody(req);
      const newId = db.responsables.length > 0 ? Math.max(...db.responsables.map(r => r.id || 0)) + 1 : 1;
      const nuevoResp = {
        id: newId,
        nombre: body.nombre,
        cargo: body.cargo || 'docente',
        area: body.area || '',
        contacto: body.contacto || body.correo || body.telefono || ''
      };
      db.responsables.push(nuevoResp);
      saveData(db);
      res.writeHead(201);
      res.end(JSON.stringify(nuevoResp));
      return;
    }

    // Endpoints ENTREGAS
    if (pathname === '/api/entregas' && req.method === 'GET') {
      res.writeHead(200);
      res.end(JSON.stringify(db.entregas));
      return;
    }

    if (pathname === '/api/entregas' && req.method === 'POST') {
      const body = await parseBody(req);
      const newId = db.entregas.length > 0 ? Math.max(...db.entregas.map(e => e.id || 0)) + 1 : 1;
      const nuevaEntrega = {
        id: newId,
        bienId: parseInt(body.bienId),
        responsableId: parseInt(body.responsableId),
        tipoEntrega: body.tipoEntrega || 'Temporal',
        fechaEntrega: body.fechaEntrega || new Date().toISOString().split('T')[0],
        cantidad: parseInt(body.cantidad) || 1,
        observacion: body.observacion || '',
        condicionEntrega: body.condicionEntrega || 'Óptimo',
        devuelto: false,
        fechaDevolucion: null,
        condicionDevolucion: null,
        presentaDano: false
      };

      // Actualizar bien stock y estado
      const bien = db.bienes.find(b => b.id === nuevaEntrega.bienId);
      if (bien) {
        bien.cantidadDisponible = Math.max(0, (bien.cantidadDisponible || 0) - nuevaEntrega.cantidad);
        if (bien.cantidadDisponible === 0) {
          bien.estado = 'Entregado';
        }
      }

      db.entregas.push(nuevaEntrega);
      saveData(db);
      res.writeHead(201);
      res.end(JSON.stringify(nuevaEntrega));
      return;
    }

    const devMatch = pathname.match(/^\/api\/entregas\/(\d+)\/devolucion$/);
    if (devMatch && req.method === 'PUT') {
      const id = parseInt(devMatch[1]);
      const body = await parseBody(req);
      const index = db.entregas.findIndex(e => e.id === id);
      if (index === -1) {
        res.writeHead(404);
        res.end(JSON.stringify({ error: 'Entrega no encontrada' }));
        return;
      }
      const entrega = db.entregas[index];
      entrega.devuelto = true;
      entrega.fechaDevolucion = body.fechaDevolucion || new Date().toISOString().split('T')[0];
      entrega.condicionDevolucion = body.condicionDevolucion || 'Devuelto sin novedad';
      entrega.presentaDano = Boolean(body.presentaDano);

      // Reglas de negocio bien:
      const bien = db.bienes.find(b => b.id === entrega.bienId);
      if (bien) {
        if (entrega.presentaDano) {
          bien.estado = 'En mantenimiento';
        } else {
          bien.cantidadDisponible = Math.min(bien.cantidadTotal, (bien.cantidadDisponible || 0) + entrega.cantidad);
          if (bien.cantidadDisponible > 0 && bien.estado === 'Entregado') {
            bien.estado = 'Disponible';
          }
        }
      }

      saveData(db);
      res.writeHead(200);
      res.end(JSON.stringify(entrega));
      return;
    }

    // Health check
    if (pathname === '/' || pathname === '/health') {
      res.writeHead(200);
      res.end(JSON.stringify({ status: 'ok', server: 'Guarda Almacen REST API' }));
      return;
    }

    res.writeHead(404);
    res.end(JSON.stringify({ error: 'Ruta no encontrada' }));
  } catch (err) {
    console.error('Server error:', err);
    res.writeHead(500);
    res.end(JSON.stringify({ error: 'Error interno del servidor' }));
  }
});

server.listen(PORT, () => {
  console.log(`Backend REST API corriendo en http://localhost:${PORT}`);
});
