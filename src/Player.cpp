#include "Player.h"
#include <algorithm>
#include <iostream>

const float Player::GRAVITY = 800.0f;
const float Player::JUMP_FORCE = -400.0f;
const float Player::MOVE_SPEED = 200.0f;
const float Player::MAX_FALL_SPEED = 500.0f;
const float Player::SHOOT_COOLDOWN = 0.5f;

Player::Player(float x, float y, SDL_Renderer* renderer) {
    mTexture = nullptr;
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
    
    // Charger la texture du GIF
    if (!LoadTexture(renderer, "src/Mario.gif")) {
        std::cerr << "Erreur: Impossible de charger Mario.gif" << std::endl;
    }
}

Player::~Player() {
    if (mTexture) {
        SDL_DestroyTexture(mTexture);
        mTexture = nullptr;
    }
}

bool Player::LoadTexture(SDL_Renderer* renderer, const char* path) {
    SDL_Surface* loadedSurface = IMG_Load(path);
    if (loadedSurface == nullptr) {
        std::cerr << "Impossible de charger l'image " << path << "! IMG_Error: " << IMG_GetError() << std::endl;
        return false;
    }
    
    // Créer la texture à partir de la surface
    mTexture = SDL_CreateTextureFromSurface(renderer, loadedSurface);
    if (mTexture == nullptr) {
        std::cerr << "Impossible de créer la texture depuis " << path << "! SDL_Error: " << SDL_GetError() << std::endl;
        SDL_FreeSurface(loadedSurface);
        return false;
    }
    
    // Obtenir les dimensions de la texture
    mTextureWidth = loadedSurface->w;
    mTextureHeight = loadedSurface->h;
    
    // Utiliser une taille fixe pour le rendu (48x48 pour un Mario de taille normale)
    // On garde les dimensions originales de la texture pour la qualité, mais on affiche à taille fixe
    float targetSize = 48.0f;  // Taille cible pour Mario petit
    mRect.w = targetSize;
    mRect.h = targetSize;
    mBaseHeight = targetSize;
    
    SDL_FreeSurface(loadedSurface);
    return true;
}

void Player::Update(float deltaTime) {
    if (mDead) return;
    
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
    
    if (mTexture) {
        // Dessiner la texture du GIF
        // Si le joueur va vers la gauche, retourner la texture
        SDL_RendererFlip flip = mFacingRight ? SDL_FLIP_NONE : SDL_FLIP_HORIZONTAL;
        SDL_RenderCopyExF(renderer, mTexture, nullptr, &renderRect, 0.0, nullptr, flip);
    } else {
        // Fallback: dessiner un rectangle rouge si la texture n'est pas chargée
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

