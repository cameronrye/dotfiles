# Setup Guide

This guide explains how to customize the dotfiles after cloning for your personal use.

## Required Customizations

After cloning this repository, you **must** update the following files with your personal information:

### 1. Git Configuration

**File:** `config/git/.gitconfig`

Update the user section with your information:

```ini
[user]
    name = YOUR_NAME          # Replace with your full name
    email = YOUR_EMAIL        # Replace with your email address
    # Uncomment and configure if using GPG signing
    # signingkey = YOUR_GPG_KEY_ID
```

**Example:**
```ini
[user]
    name = John Doe
    email = john.doe@example.com
```

### 2. NPM Configuration

**File:** `config/development/node/.npmrc`

Update the development settings:

```ini
# Development settings
init-author-name=YOUR_NAME    # Replace with your name
init-author-email=YOUR_EMAIL  # Replace with your email
init-license=MIT
init-version=1.0.0
```

**Example:**
```ini
# Development settings
init-author-name=John Doe
init-author-email=john.doe@example.com
init-license=MIT
init-version=1.0.0
```

## Quick Setup Script

You can use this one-liner to update both files at once:

```bash
# Replace YOUR_NAME and YOUR_EMAIL with your actual information
sed -i 's/YOUR_NAME/John Doe/g' config/git/.gitconfig config/development/node/.npmrc
sed -i 's/YOUR_EMAIL/john.doe@example.com/g' config/git/.gitconfig config/development/node/.npmrc
```

## Optional Customizations

### Local Configuration Files

For additional customizations that you don't want to commit to your fork, create these local files:

- `~/.zshrc.local` - Local shell configuration
- `~/.gitconfig_local` - Local git configuration  
- `~/.gitconfig_work` - Work-specific git configuration
- `~/.zshenv.local` - Local environment variables

### Work-Specific Git Configuration

If you need different git settings for work projects, create `~/.gitconfig_work`:

```ini
[user]
    name = Your Work Name
    email = your.work@company.com

[core]
    sshCommand = ssh -i ~/.ssh/work_key
```

Then the main git config will automatically include this for work directories.

## Verification

After making your changes, verify the configuration:

```bash
# Check git configuration
git config user.name
git config user.email

# Check npm configuration
npm config get init-author-name
npm config get init-author-email
```

## Next Steps

1. Run the installation script: `./install/install.sh`
2. Restart your terminal
3. Customize further using the [Customization Guide](CUSTOMIZATION.md)

For more detailed customization options, see [CUSTOMIZATION.md](CUSTOMIZATION.md).
