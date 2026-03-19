import { defineConfig } from 'vitepress'
import { withMermaid } from 'vitepress-plugin-mermaid'

export default withMermaid(
  defineConfig({
    title: 'Project Documentation',
    description: 'Architecture, decisions, and operational docs',
    themeConfig: {
      nav: [
        { text: 'PRDs', link: '/prd/' },
        { text: 'RFCs', link: '/rfc/' },
        { text: 'ADRs', link: '/adr/' },
        { text: 'Design', link: '/design/' },
        { text: 'Architecture', link: '/architecture/' },
        { text: 'Runbooks', link: '/runbooks/' },
      ],
      sidebar: 'auto',
      search: {
        provider: 'local',
      },
    },
    mermaid: {},
  })
)
