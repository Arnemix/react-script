#!/bin/bash

echo "Enter your project name: "
read -r fileName

# Convertir le nom du fichier en minuscules
lowercaseFileName=$(echo "$fileName" | tr '[:upper:]' '[:lower:]')

# Créer une nouvelle application React
npx create-react-app "$lowercaseFileName" || exit

# Accéder au répertoire du projet
cd "$lowercaseFileName" || exit

echo "Téléchargement des dépendences ..."
npm install sass react-router-dom chokidar fs-extra react-icons react-redux @reduxjs/toolkit

# Supprimer des fichiers et dossiers inutiles
rm -f ./public/favicon.ico \
    ./public/logo192.png \
    ./public/logo512.png \
    ./public/manifest.json \
    ./public/robots.txt \
    ./src/App.test.js \
    ./src/logo.svg \
    ./src/reportWebVitals.js \
    ./src/setupTests.js \
    ./src/App.css \
    ./src/index.css

# Créer des dossiers nécessaires
mkdir -p ./src/components
mkdir -p ./src/assets
mkdir -p ./src/pages
mkdir -p ./src/layouts
mkdir -p ./src/data
mkdir -p ./src/redux/store
mkdir -p ./src/redux/slices

# Créer des fichiers
touch ./src/index.scss
touch ./src/App.scss
> ./public/index.html
> ./src/index.js
> ./src/index.scss
> ./src/App.js
> ./src/App.scss
touch ./src/redux/store/store.js

# Ajouter la base du store Redux
echo "import { configureStore } from '@reduxjs/toolkit';
import todoReducer from './slices/todoSlice';

export default configureStore({
    reducer: {
        // Add reducers
    },
});
" >> ./src/redux/store/store.js

# Ajouter du contenu à App.js
echo "import './App.scss';
import { Outlet, RouterProvider, createBrowserRouter } from 'react-router-dom';

const AppLayout = () => {
    return (
        <div>
            {/* //Ajouter un layout ici (navbar etc.) */}
            <Outlet />
        </div>
    );
};

const router = createBrowserRouter([
    {
        path: '/',
        element: (
            <AppLayout>
                <Outlet />
            </AppLayout>
        ),
        children: [
            {
                // Code d'exemple
                // path: '/',
                // element: <div>Home</div>,
            },
        ],
    },
]);

export default function App() {
    return <RouterProvider router={router} />;
}" >> ./src/App.js

# Ajouter du contenu à index.js
echo "import React from 'react';
import ReactDOM from 'react-dom';
import './index.scss';
import App from './App';
import { Provider } from 'react-redux';
import store from './redux/store/store';

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
    <Provider store={store}>
        <App />
    </Provider>
);
" >> ./src/index.js

# Ajouter du contenu à index.html
echo '<!DOCTYPE html>
<html lang="fr">
    <head>
        <meta charset="utf-8" />
        <link rel="icon" href="%PUBLIC_URL%/favicon.ico" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <meta name="theme-color" content="#000000" />
        <meta
        name="description"
        content="Web site created using create-react-app"
        />
        <title>'${fileName}'</title>
    </head>
    <body>
        <div id="root"></div>
    </body>
</html>' >> ./public/index.html

# Ajouter le contenu du watcher.js
echo "const chokidar = require('chokidar');
const fs = require('fs-extra');

const sourceDirectory = './src/components'; // Ajusté pour regarder dans le dossier src/components/

// Initialise le watcher pour surveiller les changements dans le répertoire source et ses sous-dossiers
const watcher = chokidar.watch(sourceDirectory + '/**/*.jsx', {
    ignored: /(^|[/\\\\])\\../, // ignore les fichiers cachés
    persistent: true,
});

console.log(\`Le watcher est en cours d'exécution sur le répertoire \${sourceDirectory} et ses sous-dossiers\`);

// Réagit aux événements de création de fichiers
watcher.on('add', (filePath) => {
    if (filePath.endsWith('.jsx')) {
        // Génère un nom de fichier SCSS correspondant
        const scssFilePath = filePath.replace(/\\.jsx\$/, '.scss');

        // Vérifier si le fichier SCSS existe déjà
        fs.pathExists(scssFilePath, (err, exists) => {
            if (err) {
                console.error(err);
                return;
            }

            if (!exists) {
                // Crée le fichier SCSS s'il n'existe pas déjà
                fs.outputFile(scssFilePath, '// Votre contenu SCSS initial ici', (err) => {
                    if (err) throw err;
                    console.log(\`Fichier SCSS créé : \${scssFilePath}\`);
                });
            }
        });
    }
});

// Gestion des erreurs
watcher.on('error', (error) => console.error(\`Erreur du watcher: \${error}\`));

// Intercepte le signal d'arrêt et arrête proprement le watcher
process.on('SIGINT', () => {
    console.log('Arrêt du watcher');
    watcher.close();
});
" > watcher.js

# Effacer la console
clear

# Exécutez le script watcher.js en arrière-plan
node watcher.js &

# Ouvrir le projet dans VS Code
code -r .
