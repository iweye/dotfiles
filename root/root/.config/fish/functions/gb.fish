function gb --description 'Git commit with date for backups'
    git commit -m "$(date +%Y-%m-%d\ %H:%m:%S) backup"
end
