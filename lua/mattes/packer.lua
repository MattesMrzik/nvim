-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
    use {'wbthomason/packer.nvim'}

    use {
        'nvim-telescope/telescope.nvim', tag = '0.1.8',
        -- or                            , branch = '0.1.x',
        requires = { {'nvim-lua/plenary.nvim'} }
    }

    use('nvim-treesitter/nvim-treesitter', {run = ':TSUpdate'})

    use {"rebelot/kanagawa.nvim", as = "kanagawa"}

    use("mbbill/undotree")

    use("tpope/vim-fugitive")

    use('neovim/nvim-lspconfig')

    -- seems to be a requirement for cmp
    use('SirVer/ultisnips')

    -- completions
    use {
        "hrsh7th/nvim-cmp",
        requires = {
            "hrsh7th/cmp-buffer", "hrsh7th/cmp-nvim-lsp",
            'quangnguyen30192/cmp-nvim-ultisnips', 'hrsh7th/cmp-nvim-lua',
            'octaltree/cmp-look', 'hrsh7th/cmp-path', 'hrsh7th/cmp-calc',
            'f3fora/cmp-spell', 'hrsh7th/cmp-emoji'
        }
    }

    -- seems to be ai completions
    use {
        'tzachar/cmp-tabnine',
        run = './install.sh',
        requires = 'hrsh7th/nvim-cmp'
    }

    -- () {} [] auto pairs
    use {
        "windwp/nvim-autopairs",
        config = function()
            require("nvim-autopairs").setup()
        end
    }

    use {
        'lewis6991/gitsigns.nvim',
        config = function()
            require('gitsigns').setup()
        end
    }
    use {
        "folke/trouble.nvim",
        cmd = { "Trouble" },
        config = function()
            require("trouble").setup({})
        end,
    }
    use("sindrets/diffview.nvim")

    -- is a optional requirement for diffview.
    use('nvim-tree/nvim-web-devicons')

    use("nvim-treesitter/playground")

end)
