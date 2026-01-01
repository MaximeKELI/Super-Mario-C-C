#include "Player.h"
#include <algorithm>
#include <iostream>
#include <cstring>

const float Player::GRAVITY = 800.0f;
const float Player::JUMP_FORCE = -400.0f;
const float Player::MOVE_SPEED = 200.0f;
const float Player::MAX_FALL_SPEED = 500.0f;
const float Player::SHOOT_COOLDOWN = 0.5f;

Player::Player(float x, float y, SDL_Renderer* renderer) {
    mCurrentFrame = 0;
    mAnimationTime = 0.0f;
    mTextureWidth = 32;
    mTextureHeight = 32;
    mRect.x = x;
    mRect.y = y;
    mRect.w = 32.0f;
    mRect.h = 32.0f;
    mBaseHeight = 32.0f;
    mVelocityX = 0.0f;
    mVelocityY = 0.0f;
    mOnGround = false;
    mDead = false;
    mIsBig = false;
    mHasFirePower = false;
    mShootCooldown = 0.0f;
    mFacingRight = true;
    
    // Charger le GIF animé
    if (!LoadAnimatedGif(renderer, "src/Mario.gif")) {
        std::cerr << "Erreur: Impossible de charger Mario.gif, fallback sur texture simple" << std::endl;
        // Fallback: charger comme texture simple
        LoadTexture(renderer, "src/Mario.gif");
    }
}

Player::~Player() {
    // Libérer toutes les textures du GIF
    for (auto& frame : mGifFrames) {
        if (frame.texture) {
            SDL_DestroyTexture(frame.texture);
        }
    }
    mGifFrames.clear();
}

bool Player::LoadAnimatedGif(SDL_Renderer* renderer, const char* path) {
    // Utiliser IMG_LoadGIFAnimation_RW de SDL_image 2.6.0+
    SDL_RWops* rwop = SDL_RWFromFile(path, "rb");
    if (!rwop) {
        std::cerr << "Impossible d'ouvrir le fichier GIF: " << path << std::endl;
        return false;
    }
    
    IMG_Animation* anim = IMG_LoadGIFAnimation_RW(rwop);
    SDL_RWclose(rwop);
    
    if (!anim) {
        std::cerr << "Impossible de charger l'animation GIF: " << IMG_GetError() << std::endl;
        return false;
    }
    
    if (anim->count == 0) {
        std::cerr << "L'animation GIF ne contient aucune frame" << std::endl;
        IMG_FreeAnimation(anim);
        return false;
    }
    
    // Obtenir les dimensions de la première frame
    mTextureWidth = anim->w;
    mTextureHeight = anim->h;
    
    // Utiliser une taille fixe pour le rendu
    float targetSize = 48.0f;
    mRect.w = targetSize;
    mRect.h = targetSize;
    mBaseHeight = targetSize;
    
    // Charger toutes les frames dans des textures
    for (int i = 0; i < anim->count; i++) {
        SDL_Surface* frameSurface = anim->frames[i];
        if (!frameSurface) {
            continue;
        }
        
        // Copier la surface pour pouvoir libérer l'animation ensuite
        SDL_Surface* surfaceCopy = SDL_ConvertSurface(frameSurface, frameSurface->format, 0);
        if (!surfaceCopy) {
            continue;
        }
        
        // Créer la texture à partir de la copie
        SDL_Texture* texture = SDL_CreateTextureFromSurface(renderer, surfaceCopy);
        SDL_FreeSurface(surfaceCopy);
        
        if (texture) {
            GifFrame frame;
            frame.texture = texture;
            // Le délai est en millisecondes, convertir en secondes
            frame.delay = anim->delays[i] / 1000.0f;
            // Si le délai est 0, utiliser une valeur par défaut (100ms = 0.1s)
            if (frame.delay <= 0.0f) {
                frame.delay = 0.1f;
            }
            mGifFrames.push_back(frame);
        }
    }
    
    // Libérer l'animation maintenant qu'on a copié toutes les surfaces
    IMG_FreeAnimation(anim);
    
    if (mGifFrames.empty()) {
        std::cerr << "Aucune frame chargée du GIF" << std::endl;
        return false;
    }
    
    std::cout << "GIF chargé avec " << mGifFrames.size() << " frames" << std::endl;
    return true;
}

bool Player::LoadTexture(SDL_Renderer* renderer, const char* path) {
    // Fallback: charger seulement la première frame avec SDL_image
    SDL_Surface* loadedSurface = IMG_Load(path);
    if (loadedSurface == nullptr) {
        std::cerr << "Impossible de charger l'image " << path << "! IMG_Error: " << IMG_GetError() << std::endl;
        return false;
    }
    
    // Créer la texture à partir de la surface
    SDL_Texture* texture = SDL_CreateTextureFromSurface(renderer, loadedSurface);
    if (texture == nullptr) {
        std::cerr << "Impossible de créer la texture depuis " << path << "! SDL_Error: " << SDL_GetError() << std::endl;
        SDL_FreeSurface(loadedSurface);
        return false;
    }
    
    // Obtenir les dimensions de la texture
    mTextureWidth = loadedSurface->w;
    mTextureHeight = loadedSurface->h;
    
    // Utiliser une taille fixe pour le rendu
    float targetSize = 48.0f;
    mRect.w = targetSize;
    mRect.h = targetSize;
    mBaseHeight = targetSize;
    
    // Ajouter comme seule frame
    GifFrame frame;
    frame.texture = texture;
    frame.delay = 0.1f; // 100ms par défaut
    mGifFrames.push_back(frame);
    
    SDL_FreeSurface(loadedSurface);
    return true;
}

void Player::Update(float deltaTime) {
    if (mDead) return;
    
    // Mettre à jour l'animation du GIF
    if (!mGifFrames.empty()) {
        mAnimationTime += deltaTime;
        if (mAnimationTime >= mGifFrames[mCurrentFrame].delay) {
            mAnimationTime = 0.0f;
            mCurrentFrame = (mCurrentFrame + 1) % mGifFrames.size();
        }
    }
    
    // Appliquer la gravité
    if (!mOnGround) {
        mVelocityY += GRAVITY * deltaTime;
        mVelocityY = std::min(mVelocityY, MAX_FALL_SPEED);
    }
    
    // Mettre à jour la position
    mRect.x += mVelocityX * deltaTime;
    mRect.y += mVelocityY * deltaTime;
    
    // Limiter la position horizontale
    if (mRect.x < 0) {
        mRect.x = 0;
        mVelocityX = 0;
    }
    
    // Appliquer la friction horizontale
    mVelocityX *= 0.9f;
}

void Player::Render(SDL_Renderer* renderer, float cameraX) {
    if (mDead) return;
    
    SDL_FRect renderRect = mRect;
    renderRect.x -= cameraX;
    
    if (!mGifFrames.empty() && mCurrentFrame < static_cast<int>(mGifFrames.size())) {
        // Dessiner la frame actuelle du GIF
        SDL_RendererFlip flip = mFacingRight ? SDL_FLIP_NONE : SDL_FLIP_HORIZONTAL;
        SDL_RenderCopyExF(renderer, mGifFrames[mCurrentFrame].texture, nullptr, &renderRect, 0.0, nullptr, flip);
    } else {
        // Fallback: dessiner un rectangle rouge si aucune texture n'est chargée
        SDL_SetRenderDrawColor(renderer, 255, 0, 0, 255);
        SDL_RenderFillRectF(renderer, &renderRect);
    }
}

void Player::HandleInput(const Uint8* keystate) {
    if (mDead) return;
    
    // Mouvement horizontal
    if (keystate[SDL_SCANCODE_LEFT] || keystate[SDL_SCANCODE_A]) {
        mVelocityX = -MOVE_SPEED;
        mFacingRight = false;
    } else if (keystate[SDL_SCANCODE_RIGHT] || keystate[SDL_SCANCODE_D]) {
        mVelocityX = MOVE_SPEED;
        mFacingRight = true;
    }
    
    // Saut
    if ((keystate[SDL_SCANCODE_SPACE] || keystate[SDL_SCANCODE_UP] || keystate[SDL_SCANCODE_W]) && mOnGround) {
        mVelocityY = JUMP_FORCE;
        mOnGround = false;
    }
}

void Player::SetPosition(float x, float y) {
    mRect.x = x;
    mRect.y = y;
}

void Player::SetVelocity(float vx, float vy) {
    mVelocityX = vx;
    mVelocityY = vy;
}

void Player::Respawn(float x, float y) {
    SetPosition(x, y);
    SetVelocity(0, 0);
    mDead = false;
    mOnGround = false;
    // Garder les power-ups après respawn (optionnel - on peut les réinitialiser)
    // mIsBig = false;
    // mHasFirePower = false;
}

void Player::CollectMushroom() {
    if (!mIsBig) {
        mIsBig = true;
        mRect.h = mBaseHeight * 1.5f;
        mRect.y -= mBaseHeight * 0.5f; // Ajuster la position
    }
}

void Player::CollectFireFlower() {
    mHasFirePower = true;
    if (!mIsBig) {
        CollectMushroom(); // La fleur de feu grandit aussi Mario
    }
}

void Player::Shrink() {
    if (mIsBig) {
        mIsBig = false;
        mHasFirePower = false;
        mRect.h = mBaseHeight;
        mRect.y += mBaseHeight * 0.5f; // Ajuster la position
    }
}

void Player::Shoot() {
    if (CanShoot()) {
        mShootCooldown = SHOOT_COOLDOWN;
        // La logique de création de la boule de feu sera dans Game
    }
}

void Player::UpdateShootCooldown(float deltaTime) {
    if (mShootCooldown > 0) {
        mShootCooldown -= deltaTime;
    }
}
