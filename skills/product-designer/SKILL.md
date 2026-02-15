---
name: product-designer
description: Create user-centered UI/UX designs — develop wireframes, prototypes, design systems, user flows, and accessibility-compliant interfaces following best practices.
metadata: {"openclaw":{"emoji":"🎨"}}
---

# Product Designer

Guide AI agents in creating thoughtful, user-centered UI/UX designs. This skill covers design thinking, wireframing, prototyping, accessibility, and modern design patterns.

## Core Principles

### User-Centered Design
- **Empathy First**: Understand user needs, pain points, and goals before designing
- **Accessibility**: Follow WCAG 2.1 AA standards minimum (AAA where possible)
- **Inclusive Design**: Design for diverse users, abilities, devices, and contexts
- **Usability**: Prioritize clarity, efficiency, and error prevention

### Design System Thinking
- **Consistency**: Establish patterns that scale across the product
- **Component-Based**: Build reusable UI components with clear hierarchies
- **Documentation**: Define usage guidelines, states, and variations
- **Tokens**: Use design tokens for colors, spacing, typography

## Design Process

### 1. Discovery & Research
```markdown
## User Research Checklist
- [ ] Define target users and personas
- [ ] Identify user goals and pain points
- [ ] Map user journeys and touchpoints
- [ ] Review competitor solutions
- [ ] Analyze existing analytics/feedback (if available)
```

### 2. Information Architecture
- Create site maps and content hierarchies
- Define navigation patterns and taxonomies
- Plan user flows for key tasks
- Establish mental models and metaphors

### 3. Wireframing
Start with low-fidelity wireframes to explore layout and structure:

```
Low-Fidelity Wireframe Elements:
┌────────────────────────────┐
│ [Header / Navigation]      │
├────────────────────────────┤
│ [Hero / Primary Content]   │
│                            │
│ [Key Actions/CTAs]         │
├────────────────────────────┤
│ [Secondary Content]        │
│ [Grid / Card Layout]       │
├────────────────────────────┤
│ [Footer]                   │
└────────────────────────────┘
```

**Wireframe Best Practices:**
- Focus on structure, not aesthetics
- Use real content (or realistic placeholders)
- Show content priority and hierarchy
- Indicate interactive elements
- Include annotations for behavior

### 4. High-Fidelity Design
Apply visual design to validated wireframes:

**Visual Hierarchy:**
- Size, color, contrast for importance
- Whitespace to create breathing room
- Typography scale (6-8 levels typical)
- Grid systems (8px or 4px base)

**Color Systems:**
- Primary (brand identity)
- Secondary (supporting actions)
- Neutral (backgrounds, borders, text)
- Semantic (success, warning, error, info)
- Ensure 4.5:1 contrast ratio for text

**Typography:**
- Font pairing (1-2 typefaces max)
- Type scale (e.g., 12, 14, 16, 20, 24, 32, 48, 64)
- Line height (1.4-1.6 for body, 1.2-1.3 for headings)
- Font weights (Regular 400, Medium 500, Bold 700)

### 5. Interactive Prototyping
- Add micro-interactions and animations
- Show state changes (hover, active, disabled, loading)
- Define transitions between screens
- Test with users for feedback

## Design Patterns

### Layout Patterns
- **F-Pattern**: Text-heavy pages (blogs, articles)
- **Z-Pattern**: Simple pages with key CTAs
- **Grid Layout**: Content galleries, dashboards
- **Card Pattern**: Modular, scannable content
- **Split Screen**: Comparison or dual-purpose views

### Navigation Patterns
- **Top Nav**: Global navigation, 5-7 items max
- **Sidebar**: Deep hierarchies, admin panels
- **Hamburger Menu**: Mobile-first, space-constrained
- **Tabs**: Content organization within a page
- **Breadcrumbs**: Show hierarchy, aid navigation

### Component Patterns
- **Buttons**: Primary, secondary, tertiary, ghost
- **Forms**: Clear labels, inline validation, error states
- **Modals**: Focus attention, confirm actions
- **Toast/Snackbar**: Non-intrusive notifications
- **Tooltips**: Contextual help on hover/focus
- **Cards**: Grouped information with actions
- **Tables**: Data presentation with sorting/filtering
- **Empty States**: Guide users when no content exists

### Interaction Patterns
- **Progressive Disclosure**: Show complexity gradually
- **Lazy Loading**: Load content as needed
- **Infinite Scroll**: For feeds and timelines
- **Pull to Refresh**: Mobile content updates
- **Skeleton Screens**: Show structure while loading
- **Optimistic UI**: Assume success, update immediately

## Accessibility (A11y)

### WCAG 2.1 AA Compliance
- **Perceivable**: Text alternatives, captions, color contrast
- **Operable**: Keyboard navigation, timing adjustments
- **Understandable**: Readable text, predictable behavior
- **Robust**: Compatible with assistive technologies

### Key Considerations
- **Color Contrast**: 4.5:1 for normal text, 3:1 for large text
- **Keyboard Navigation**: All interactive elements accessible via Tab
- **Focus Indicators**: Visible focus states (never remove outlines)
- **Alt Text**: Descriptive text for images, icons
- **ARIA Labels**: For screen readers when visual labels insufficient
- **Semantic HTML**: Use proper heading hierarchy (h1-h6)
- **Form Labels**: Every input needs an associated label
- **Touch Targets**: Minimum 44x44px for mobile

### Testing Tools
- **Contrast Checkers**: WebAIM, Stark, Adobe Color
- **Screen Readers**: NVDA (Windows), JAWS, VoiceOver (Mac/iOS)
- **Keyboard Testing**: Navigate entire interface without mouse
- **Automated Audits**: Lighthouse, axe DevTools, WAVE

## Responsive Design

### Breakpoints (Common)
```
Mobile:  320px - 767px
Tablet:  768px - 1023px
Desktop: 1024px - 1439px
Wide:    1440px+
```

### Mobile-First Approach
1. Design for smallest screen first
2. Add complexity as screen size increases
3. Touch-friendly targets (44x44px min)
4. Readable text without zooming (16px min)
5. Avoid horizontal scrolling

### Desktop Considerations
- Optimize for mouse/keyboard interactions
- Use screen space effectively (don't just stretch)
- Multi-column layouts when appropriate
- Keyboard shortcuts for power users

## Design Systems

### Component Library Structure
```
Foundation
├── Colors (primitives & semantic)
├── Typography (scale, fonts, weights)
├── Spacing (4px or 8px base unit)
├── Shadows & Elevation
└── Border Radius

Components
├── Atoms (buttons, inputs, icons)
├── Molecules (form fields, cards)
├── Organisms (headers, forms, modals)
└── Templates (page layouts)
```

### Documentation Template
```markdown
## Component Name

### Purpose
What problem does this solve?

### Anatomy
Visual breakdown of component parts

### Variants
- Default
- States (hover, focus, active, disabled, error)
- Sizes (small, medium, large)
- Themes (light, dark)

### Usage Guidelines
When to use / when not to use

### Accessibility
- Keyboard navigation
- ARIA attributes
- Screen reader announcements

### Code Example
[Link to implementation]
```

## Tools & Deliverables

### Design Tools
- **Figma**: Collaborative UI design
- **Sketch**: Mac-based design tool
- **Adobe XD**: All-in-one UX/UI solution
- **Framer**: Interactive prototypes with code
- **InVision**: Prototyping and handoff

### Wireframing Tools
- **Balsamiq**: Low-fidelity mockups
- **Whimsical**: Flow diagrams and wireframes
- **Miro/Mural**: Collaborative whiteboarding
- **Excalidraw**: Simple sketching

### Prototyping Tools
- **Principle**: Animation and interaction
- **ProtoPie**: Advanced interactions without code
- **Framer Motion**: React-based animations

### Handoff & Documentation
- **Zeplin**: Design-to-development handoff
- **Storybook**: Component documentation and playground
- **Supernova**: Design system platform

### Common Deliverables
- User personas and journey maps
- Information architecture diagrams
- Low-fidelity wireframes
- High-fidelity mockups
- Interactive prototypes
- Design system documentation
- Component specifications
- Accessibility audit reports

## When to Use This Skill

**Triggers:**
- "Design a dashboard for..."
- "Create wireframes for..."
- "What's the best pattern for..."
- "How should this form be laid out?"
- "Make this more accessible"
- "Create a design system for..."
- "What are best practices for [UI element]?"

**Process:**
1. Clarify user needs and constraints
2. Research similar solutions and patterns
3. Create wireframes or flows
4. Apply visual design and branding
5. Ensure accessibility compliance
6. Document design decisions and rationale
7. Prepare handoff materials for developers

## Best Practices

### Design Thinking
- Start with the problem, not the solution
- Iterate based on feedback and testing
- Design for the 80% use case first
- Plan for edge cases and error states
- Consider performance implications

### Collaboration
- Include developers early in the process
- Share design rationale, not just screens
- Use design systems to maintain consistency
- Document design decisions and alternatives considered
- Provide redlines and specifications for implementation

### Quality Checks
- [ ] All interactive elements have hover/focus states
- [ ] Error states and validation messages defined
- [ ] Loading states and empty states designed
- [ ] Responsive behavior specified for all breakpoints
- [ ] Color contrast meets WCAG AA standards
- [ ] All text is readable and scannable
- [ ] Navigation is intuitive and consistent
- [ ] Forms are simple and validation is helpful
- [ ] Touch targets meet minimum size requirements
- [ ] Design works in light and dark modes (if applicable)

## Resources

### Design Inspiration
- **Dribbble**: Design showcase and trends
- **Behance**: Portfolio and case studies
- **Mobbin**: Mobile design patterns library
- **UI Garage**: Categorized design patterns
- **Refactoring UI**: Practical design tips

### Guidelines
- **Material Design**: Google's design system
- **Human Interface Guidelines**: Apple's design principles
- **Fluent Design**: Microsoft's design system
- **Carbon Design**: IBM's design system
- **Lightning Design**: Salesforce design system

### Learning
- **Laws of UX**: Psychology-based design principles
- **Nielsen Norman Group**: UX research and guidelines
- **A List Apart**: Web design and development insights
- **Smashing Magazine**: Design and development articles

### Accessibility
- **WebAIM**: Web accessibility guidance and tools
- **A11y Project**: Accessibility checklist and resources
- **Inclusive Components**: Accessible component patterns
- **Deque University**: Accessibility training

## Tips for AI Agents

1. **Ask Clarifying Questions**: Understand the context, users, and constraints before designing
2. **Show Your Work**: Explain design decisions with rationale
3. **Use ASCII Art**: For quick wireframes in text format
4. **Reference Patterns**: Point to established patterns rather than reinventing
5. **Think Systematically**: Consider how this design fits into the larger product
6. **Accessibility First**: Design with accessibility in mind from the start, not as an afterthought
7. **Mobile Matters**: Consider mobile experience even for desktop-first products
8. **Content is King**: Design around real content, not lorem ipsum
9. **Performance Aware**: Consider load times, image sizes, and perceived performance
10. **Document Decisions**: Capture why choices were made for future reference
