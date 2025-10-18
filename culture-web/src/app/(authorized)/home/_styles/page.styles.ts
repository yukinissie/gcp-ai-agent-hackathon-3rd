export const homeStyles = {
  mainContainer: {
    minHeight: '100vh',
  },
  mainContent: {
    flex: 1,
    transition: 'margin-right 0.3s ease',
    marginRight: '0',
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
