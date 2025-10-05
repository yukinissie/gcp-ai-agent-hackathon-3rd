export const homeStyles = {
  mainContainer: {
    height: '100vh',
  },
  mainContent: {
    flex: 1,
    overflow: 'auto' as const,
    transition: 'margin-right 0.3s ease',
    marginRight: '0',
    overflowX: 'auto' as const,
    overflowY: 'auto' as const,
    transitionProperty: 'margin-right',
    transitionDuration: '0.3s',
    transitionTimingFunction: 'ease',
    transitionDelay: '0s',
    transitionBehavior: 'normal',
    position: 'relative' as const,
    flexGrow: '1',
    flexShrink: '1',
    flexBasis: '0%',
  },
}
